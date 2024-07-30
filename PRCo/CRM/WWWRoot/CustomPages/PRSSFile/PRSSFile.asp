<!-- #include file ="..\accpaccrm.js" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2024

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/
%>

<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="../PRCompany/CompanyIdInclude.asp" -->
<!-- #include file ="..\PRTES\PRTESCustomRequestFunctions.asp" -->

<html>

<head>
    <link href="/crm/Themes/ergonomic.css?83568" rel="stylesheet">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
</head>

<%

var sInitializeTasks = "";
var prss_ssfileid = getIdValue("prss_ssfileid");
doPage();

function doPage()
{
    var key58Redirect = handleKey58();
    if (key58Redirect != null) {
        Response.Redirect(Request.ServerVariables("URL")+ "?" + key58Redirect);
    }

    sClaimantContactTag = "";
    sRespondentContactTag = "";
    s3rdPartyContactTag = "";
    //bDebug = true;
    DEBUG(sURL);
    
    if (getFormValue("_hiddenCreateTES") == "R") {
        recSSFile = eWare.FindRecord("PRSSFile", "prss_ssfileid="+ prss_ssfileid);
        var szCompanyIDs = Request.Form.Item("cbInvestigation").item;
        var szMessage = createTES(recSSFile("prss_ClaimantCompanyId"), recSSFile("prss_RespondentCompanyId"), null, null, user_userid);
        eWare.Mode = View;
    }

    if (getFormValue("_hiddenCreateTES") == "C") {
        recSSFile = eWare.FindRecord("PRSSFile", "prss_ssfileid="+ prss_ssfileid);
        var szCompanyIDs = Request.Form.Item("cbInvestigation").item;
        var szMessage = createTES(recSSFile("prss_RespondentCompanyId"), recSSFile("prss_ClaimantCompanyId"), null, null, user_userid);
        eWare.Mode = View;
    }

    %>
    
    <script type="text/javascript" src="../CKFields.js"></script>
    <script type="text/javascript" src="../../ckeditor/ckeditor.js"></script>
    <script type="text/javascript">CKFields('prss_recordofactivity');</script>

    <%
    var szRoA = getIdValue("RoA");

    blkContainer = eWare.GetBlock('container');
    blkContainer.CheckLocks = false;
    blkContainer.DisplayButton(Button_Default) = false;

    var sKey0 = getIdValue("Key0");
    var sSecurityGroups = "1,2,3,4,5,6,7,8,9,10,11";
    
    blkMain=eWare.GetBlock("PRSSFileAllInfo");
    blkMain.Title="Special Services File";
    var fldSSFile = blkMain.GetEntry("prss_ssfileid");
    fldSSFile.ReadOnly = true;
    fldCreatedBy = blkMain.GetEntry("prss_CreatedBy");

    CapPos = 6;
    //blkMain.getEntry("prss_InitialAmountOwed").CaptionPos = CapPos;
    //blkMain.getEntry("prss_OldestInvoiceDate").CaptionPos = CapPos;
    //blkMain.getEntry("prss_AmountPRCoCollected").CaptionPos = CapPos;
    //blkMain.getEntry("prss_NumberOfInvoices").CaptionPos = CapPos;
    //blkMain.getEntry("prss_AmountPRCoInvoiced").CaptionPos = CapPos;
    //blkMain.getEntry("prss_PartialInvoice").CaptionPos = CapPos;

    entry = blkMain.getEntry("prss_AmountStillOwing");
    entry.ReadOnly = true;
    //entry.CaptionPos = CapPos;
    entry = blkMain.getEntry("prss_pacadeadlinedate");
    entry.ReadOnly = true;
    //entry.CaptionPos = CapPos;

    //Defect 5514
    var closedReason = blkMain.getEntry("prss_ClosedReason");
    closedReason.LookupFamily = "prss_ClosedReason_Edit"; //Always show 6 new items per defect 4650

    //blkMain.getEntry("prss_WorkingAssessment").CaptionPos = CapPos;
    //blkMain.getEntry("prss_ClaimAuthSentDate").CaptionPos = CapPos;
    //blkMain.getEntry("prss_PLANRefAuthSentDate").CaptionPos = CapPos;
    //blkMain.getEntry("prss_ClaimAuthRcvdDate").CaptionPos = CapPos;
    //blkMain.getEntry("prss_PLANRefAuthRcvdDate").CaptionPos = CapPos;
    //blkMain.getEntry("prss_A1LetterSentDate").CaptionPos = CapPos;
    //blkMain.getEntry("prss_FileSentToPLANDate").CaptionPos = CapPos;
    //blkMain.getEntry("prss_D1LetterSentDate").CaptionPos = CapPos;
    //blkMain.getEntry("prss_PLANPartner").CaptionPos = CapPos;
    //blkMain.getEntry("prss_WarningLetterSentDate").CaptionPos = CapPos;
    //blkMain.getEntry("prss_PLANFileNumber").CaptionPos = CapPos;
    //blkMain.getEntry("prss_ReportLetterSentDate").CaptionPos = CapPos;
    //blkMain.getEntry("prss_PLANFileResult").CaptionPos = CapPos;
    //blkMain.getEntry("prss_NumeralReportDate").CaptionPos = CapPos;
    //blkMain.getEntry("prss_ClaimantTradeReportDate").CaptionPos = CapPos;
    //blkMain.getEntry("prss_ClaimantTradeReportDate").ReadOnly = true;;
    //blkMain.getEntry("prss_ReportReinstateSentDate").CaptionPos = CapPos;
    //blkMain.getEntry("prss_NumeralReinstateSentDate").CaptionPos = CapPos;
    //blkMain.getEntry("prss_FinalNoticeLetterSentDate").CaptionPos = CapPos;

    //blkMain.GetEntry("prss_MeritoriousDate").ReadOnly = true;
    blkMain.GetEntry("prss_CATDataChanged").ReadOnly = true;
    blkMain.GetEntry("prss_Meritorious").DefaultValue = "UR";
    blkMain.GetEntry("prss_StatusDescription").DefaultValue = "Blue Book review ongoing.";

    // indicate that this is new
    if (prss_ssfileid == "-1")
    {
        var bNew = true;
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }
    sListingAction = eWare.Url("PRSSFile/PRSSFileListing.asp") + "&T=Company&Capt=Special+Services+Files";
    sSummaryAction = eWare.Url("PRSSFile/PRSSFile.asp")+ "&prss_ssfileid="+ prss_ssfileid + "&T=Company&Capt=Special+Services+Files";

    Response.Write("<link rel=\"stylesheet\" href=\"/" + sInstallName + "/prco.css\">");  
    Response.Write("<link rel=\"stylesheet\" href=\"/" + sInstallName + "/prco_compat.css\">");  
    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");  
    Response.Write("<script type=\"text/javascript\" src=\"PRSSFile.js\"></script>");  

    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        if (bNew)
        {
            recSSFile = eWare.CreateRecord("PRSSFile");
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
            // defaults
            fldCreatedBy.DefaultValue = user_userid;
            
            // set prco assistance defaults
            fldInitialAmountOwed = blkMain.GetEntry("prss_initialamountowed");
            fldInitialAmountOwed.DefaultValue = 0.00;
            fldAmountPRCoCollected = blkMain.GetEntry("prss_amountprcocollected");
            fldAmountPRCoCollected.DefaultValue = 0.00;

            fldPublish = blkMain.GetEntry("prss_publish");
            fldPublish.DefaultValue = true;

            var feepct = 10;
            var feetype = 0;

            sServiceCode = 'BASIC'
            companyid = getIdValue("Key1");
            if (companyid != "-1")
            {
                sql = "SELECT prse_CompanyID, prse_HQID, prse_ServiceCode FROM PRService WITH(NOLOCK) WHERE prse_HQID=" + companyid + " AND prse_Primary='Y'";
                qryTemp = eWare.CreateQueryObj(sql);
                qryTemp.SelectSql();
                if (!qryTemp.eof){
                    sServiceCode = qryTemp("prse_ServiceCode");
                }

                var isARSubmitter = false;
                var recARAgingHeader = eWare.FindRecord("PRCompanyInfoProfile", "prc5_CompanyId = " + companyid + " AND prc5_ARSubmitter='Y'");
                var sARAgingHeader = recARAgingHeader.prc5_ARSubmitter;
                if (!isEmpty(sARAgingHeader)) {
                    isARSubmitter = true;
                }


                if(isARSubmitter)
                {
                    //AR Submitter
                    switch(sServiceCode) {
                        case "BASIC":
                            feepct = 5;
                            break;
                        case "STANDARD":
                            feepct = 2;
                            break;
                        case "PREMIUM":
                            feepct = 0;
                            feetype = 1;
                            break;
                        case "ENTERPRISE":
                            feepct = 0;
                            feetype = 1;
                            break;
                        default:
                            feepct = 5;
                            break;
                    }
                }
                else
                {
                    //Not AR Submitter
                    switch(sServiceCode) {
                        case "BASIC":
                            feepct = 10;
                            break;
                        case "STANDARD":
                            feepct = 5;
                            break;
                        case "PREMIUM":
                            feepct = 2;
                            break;
                        case "ENTERPRISE":
                            feepct = 2;
                            break;
                        default:
                            feepct = 10;
                            break;
                    }
                }
            }

            recSSFile.prss_PRCOAssistanceFeeType = feetype;
            recSSFile.prss_PRCOAssistanceFeePct = feepct;
            
            fldAssignedUserId = blkMain.GetEntry("prss_assigneduserid");
            fldAssignedUserId.DefaultValue = recUser.user_userid;
            
            if (companyid != "-1")
            {
                fldClaimantCompanyId = blkMain.GetEntry("prss_claimantcompanyid");
                fldClaimantCompanyId.DefaultValue = companyid;
            }
	    }
        else
        {
            recSSFile = eWare.FindRecord("PRSSFile", "prss_ssfileid="+ prss_ssfileid);
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
	    }
        if (eWare.Mode == Save)
        {
            prss_assistancefeetype = getFormValue("prss_prcoassistancefeetype");
            prss_assistancefeepct = getFormValue("prss_prcoassistancefeepct");
            if (isEmpty(prss_assistancefeepct))
                prss_assistancefeepct = "";
                
            prss_assistancefee = getFormValue("prss_prcoassistancefee");
            if (isEmpty(prss_assistancefee))
                prss_assistancefee = "";
                
            recSSFile.prss_PRCoAssistanceFeeType = prss_assistancefeetype;
            recSSFile.prss_PRCoAssistanceFeePct = prss_assistancefeepct;
            recSSFile.prss_PRCoAssistanceFee = prss_assistancefee;
            if (prss_assistancefeetype == 1)
            {
                recSSFile.prss_PRCoAssistanceFeePct = "";
            }
            recSSFile.prss_ChannelId = recUser("user_PrimaryChannelId");
            
        }
        if (isUserInGroup(sSecurityGroups ))
	        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();\""));
	}
    else if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the record
        sql = "DELETE FROM PRSSFile WHERE prss_SSFileId="+ prss_ssfileid;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
	    return;
    }
    else 
    {
        recSSFile = eWare.FindRecord("PRSSFile", "prss_ssfileid="+ prss_ssfileid);

        if (getFormValue("_hiddenCreateTES") == "R") {
            var szCompanyIDs = Request.Form.Item("cbInvestigation").item;
            var szMessage = createTES(recSSFile("prss_ClaimantCompanyId"), recSSFile("prss_RespondentCompanyId"), null, null, user_userid);
        }

        if (getFormValue("_hiddenCreateTES") == "C") {
            var szCompanyIDs = Request.Form.Item("cbInvestigation").item;
            var szMessage = createTES(recSSFile("prss_RespondentCompanyId"), recSSFile("prss_ClaimantCompanyId"), null, null, user_userid);
        }
    
        var claimantCompName = "";
        var respondentCompName = "";

        // determine the additional mods required for the File Parties
        prss_claimantcompanyid = recSSFile("prss_ClaimantCompanyId");
    
        if (!isEmpty(prss_claimantcompanyid) && (prss_claimantcompanyid != -1))
        {
            // claimant requires a little extra work.
            // determine the listing status and current rating
            sql = "SELECT dbo.ufn_getCurrentRatingLine(comp_companyid) as Rating, capt_US "
                + " FROM Company WITH (NOLOCK) "
                + " INNER JOIN custom_captions on capt_family = 'comp_PRListingStatus' and capt_code = comp_PRListingStatus "
                + " WHERE comp_CompanyId="+ prss_claimantcompanyid;
            qryTemp = eWare.CreateQueryObj(sql);
            qryTemp.SelectSql();
            if (!qryTemp.eof){
                sRating = qryTemp("Rating");
                if (isEmpty(sRating))
                    sRating = "";
                sStatus = qryTemp("capt_US");
                if (isEmpty(sStatus))
                    sStatus = "";
                sAddlFields = "<div style=\"display:none\"><table >"+
                    "<tr id=\"_trListingInfo\"><td colspan=\"4\" class=\"VIEWBOX\" valign=\"TOP\" ><span class=\"VIEWBOXCAPTION\">&nbsp;&nbsp;Listing Status:</span> <span class=\"VIEWBOX\">"+ sStatus + "</span></td></tr>"+
                    "<tr id=\"_trRatingInfo\"><td colspan=\"4\" class=\"VIEWBOX\" valign=\"TOP\" ><span class=\"VIEWBOXCAPTION\">&nbsp;&nbsp;Current Rating:</span> <span class=\"VIEWBOX\">"+ sRating + "</span></td></tr>"+
                    "</table></div>";     
                Response.Write(sAddlFields);
                sClaimantContactTag += "\n    AppendRow(\"_Captprss_claimantcompanyid\", \"_trRatingInfo\"); "  
                sClaimantContactTag += "\n    AppendRow(\"_Captprss_claimantcompanyid\", \"_trListingInfo\"); "  
            }

            sClaimantContactTag += setupPrimaryContact("Claimant", prss_claimantcompanyid);
            recClaimantSearch = eWare.FindRecord("PRCompanySearch", "prcse_companyid=" + prss_claimantcompanyid);
            sInitializeTasks += "setFieldValue(\"_Dataprss_claimantcompanyid\", \"" + recClaimantSearch("prcse_FullName") + "\");";
            
            sClaimantUrl = eWare.Url("PRCompany/PRCompanySummary.asp");
            sClaimantUrl = changeKey(sClaimantUrl, "Key0", "1");
            sClaimantUrl = changeKey(sClaimantUrl, "Key1", prss_claimantcompanyid);
            sClaimantUrl = removeKey(sClaimantUrl, "Key58");

            sInitializeTasks += "setFieldValue(\"_Dataprss_claimantcompanyid\", \"<a id=claimantcompanylink href='" +sClaimantUrl + "' >" + recClaimantSearch("prcse_FullName") + "</a>\");";

            var recClaimantComp = eWare.FindRecord("Company", "comp_companyid=" + prss_claimantcompanyid);
            claimantCompName = recClaimantComp("comp_Name");
        }

        prss_respondentcompanyid = recSSFile("prss_RespondentCompanyId");
        if (!isEmpty(prss_respondentcompanyid ) && (prss_respondentcompanyid != -1)) {
            // respondent requires a little extra work.
            // determine the listing status and current rating
            sql = "SELECT dbo.ufn_getCurrentRatingLine(comp_companyid) as Rating, capt_US "
                + " FROM Company WITH (NOLOCK) "
                + " INNER JOIN custom_captions on capt_family = 'comp_PRListingStatus' and capt_code = comp_PRListingStatus "
                + " WHERE comp_CompanyId="+ prss_respondentcompanyid ;
            qryTemp = eWare.CreateQueryObj(sql);
            qryTemp.SelectSql();
            if (!qryTemp.eof){
                sRating = qryTemp("Rating");
                if (isEmpty(sRating))
                    sRating = "";
                sStatus = qryTemp("capt_US");
                if (isEmpty(sStatus))
                    sStatus = "";
                sAddlFields = "<div style=\"display:none\"><table >"+
                    "<tr id=\"_trListingInfo\"><td colspan=\"4\" class=\"VIEWBOX\" valign=\"TOP\" ><span class=\"VIEWBOXCAPTION\">&nbsp;&nbsp;Listing Status:</span> <span class=\"VIEWBOX\">"+ sStatus + "</span></td></tr>"+
                    "<tr id=\"_trRatingInfo\"><td colspan=\"4\" class=\"VIEWBOX\" valign=\"TOP\" ><span class=\"VIEWBOXCAPTION\">&nbsp;&nbsp;Current Rating:</span> <span class=\"VIEWBOX\">"+ sRating + "</span></td></tr>"+
                    "</table></div>";     
                Response.Write(sAddlFields);
                sRespondentContactTag += "\n    AppendRow(\"_Captprss_respondentcompanyid\", \"_trRatingInfo\"); "  
                sRespondentContactTag += "\n    AppendRow(\"_Captprss_respondentcompanyid\", \"_trListingInfo\"); "  
            }
            sRespondentContactTag += setupPrimaryContact("Respondent", prss_respondentcompanyid);
            recRespondentSearch = eWare.FindRecord("PRCompanySearch", "prcse_companyid=" + prss_respondentcompanyid);
            sInitializeTasks += "setFieldValue(\"_Dataprss_respondentcompanyid\", \"" + recRespondentSearch("prcse_FullName") + "\");";

            sRespondentUrl = eWare.Url("PRCompany/PRCompanySummary.asp");
            sRespondentUrl = changeKey(sRespondentUrl, "Key0", "1");
            sRespondentUrl = changeKey(sRespondentUrl, "Key1", prss_respondentcompanyid);
            sRespondentUrl = removeKey(sRespondentUrl, "Key58");

            sInitializeTasks += "setFieldValue(\"_Dataprss_respondentcompanyid\", \"<a id=respondentcompanylink href='" +sRespondentUrl + "' >" + recRespondentSearch("prcse_FullName") + "</a>\");";

            var recRespondentComp = eWare.FindRecord("Company", "comp_companyid=" + prss_respondentcompanyid);
            respondentCompName = recRespondentComp("comp_Name");
        }

        var clipboardString = prss_ssfileid + " - ";
        clipboardString += claimantCompName;
        clipboardString += " &amp; ";
        clipboardString += respondentCompName;

        blkMain.Title += "&nbsp;&nbsp;&nbsp;<a style=\"font-size:9pt\" href=\"javascript:CopyStringToClipboard('" + clipboardString + "');\" title=\"This copies the SS File Number, Claimant Company Name & Responder Company Name to the clipboard.\">(Copy to Clipboard)</a>";


        prss_3rdpartycompanyid = recSSFile("prss_3rdPartyCompanyId");
        if (!isEmpty(prss_3rdpartycompanyid ))
        {
            s3rdPartyContactTag = setupPrimaryContact("3rdParty", prss_3rdpartycompanyid);
            rec3rdPartySearch = eWare.FindRecord("PRCompanySearch", "prcse_companyid=" + prss_3rdpartycompanyid);

            s3rdPartyUrl = eWare.Url("PRCompany/PRCompanySummary.asp");
            s3rdPartyUrl = changeKey(s3rdPartyUrl, "Key0", "1");
            s3rdPartyUrl = changeKey(s3rdPartyUrl, "Key1", prss_3rdpartycompanyid);
            s3rdPartyUrl = removeKey(s3rdPartyUrl, "Key58");

            sInitializeTasks += "setFieldValue(\"_Dataprss_3rdpartycompanyid\", \"<a id=Thirdpartycompanylink href='" +s3rdPartyUrl + "' >" + rec3rdPartySearch("prcse_FullName") + "</a>\");";
        }

        sListingAction += "&key0=1&key1=" + recSSFile("prss_ClaimantCompanyId");
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        
        var sCATHistoryURL = eWare.URL("PRSSFile/PRSSCATHistoryListing.asp") + "&prss_ssfileid=" + recSSFile("prss_ssfileid");
        sCATHistoryURL = changeKey(sCATHistoryURL, "Key0", "1");
        sCATHistoryURL = changeKey(sCATHistoryURL, "Key1", prss_claimantcompanyid);
        blkContainer.AddButton(eWare.Button("View CAT History","continue.gif", sCATHistoryURL));


        if ((!isEmpty(prss_respondentcompanyid ))  &&
            (!isEmpty(prss_claimantcompanyid ))) {
            var sTradeReportUrl = eWare.URL("PRCompany/PRCompanyTradeReport.asp") + "&IsSSFile=1&prtr_SubjectId=" + prss_respondentcompanyid + "&prtr_ResponderId=" + prss_claimantcompanyid + "&prss_ssfileid=" + prss_ssfileid;
            blkContainer.AddButton(eWare.Button("New Trade Report", "new.gif", sTradeReportUrl));
        }

        /*
         * This is a special block just used to get our 
         * hidden flag fields on the form
         */
        blkFlags = eWare.GetBlock("content");
        blkFlags.Contents = "<input type=\"hidden\" name=\"_hiddenCreateTES\" id=\"_hiddenCreateTES\">";
        blkContainer.AddBlock(blkFlags);


        var attentionLine = eWare.FindRecord("vPRCompanyAttentionLine", "prattn_CompanyID = " + prss_claimantcompanyid + " AND prattn_ItemCode = 'TES-E' AND prattn_Disabled IS NULL");
        if (!attentionLine.eof) {
            blkContainer.AddButton(eWare.Button("Create TES Request for Claimant","new.gif","javascript:confirmTES('C');"));
        }

        //attentionLine = eWare.FindRecord("vPRCompanyAttentionLine", "prattn_CompanyID = " + prss_respondentcompanyid + " AND prattn_ItemCode = 'TES-E' AND prattn_Disabled IS NULL");
        //if (!attentionLine.eof) {
        //    blkContainer.AddButton(eWare.Button("Create TES Request for Respondent","new.gif","javascript:confirmTES('R');"));   
        //}
        
        

        if (isUserInGroup(sSecurityGroups ))
        {
            // we are removing the delete button just prior to 2.5 release based upon SSFile Mngr recommendation
            //sDeleteUrl = changeKey(sURL, "em", "3");
            //blkContainer.AddButton(eWare.Button("Delete", "delete.gif", "javascript:location.href='"+sDeleteUrl+"';"));
            blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));

            if (!isEmpty(prss_respondentcompanyid))
            {
                var sSQL = " SELECT dbo.ufn_GetCustomCaptionValue('SSRS', 'URL', 'en-us') as SSRSURL ";
                var recSSRS = eWare.CreateQueryObj(sSQL);
                recSSRS.SelectSQL();                
                var SSRSURL = getValue(recSSRS("SSRSURL"));
                blkContainer.AddButton(eWare.Button("Claims Filed Report","componentpreview.gif", "javascript:openClaimsFiledReport(" + prss_respondentcompanyid + ",'" + SSRSURL + "')"));
            }
        }
        if (isEmpty(recSSFile("prss_OpenedByUserId")))
        {
            fldOpenedBy = blkMain.GetEntry("prss_OpenedByUserId");
            fldOpenedBy.Hidden = true;
            fldOpenedDate = blkMain.GetEntry("prss_OpenedDate");
            fldOpenedDate.Hidden = true;
        }
        if (isEmpty(recSSFile("prss_ClosedByUserId")))
        {
            fldClosedBy = blkMain.GetEntry("prss_ClosedByUserId");
            fldClosedBy.Hidden = true;
            fldClosedDate = blkMain.GetEntry("prss_ClosedDate");
            fldClosedDate.Hidden = true;
            fldClosedReason = blkMain.GetEntry("prss_ClosedReason");
            fldClosedReason.Hidden = true;
        }

        blkContainer.AddButton("Party&nbsp;Actions:");
        sContactAction = eWareUrl("PRSSFile/PRSSContact.asp") + "&prss_ssfileid="+ recSSFile("prss_ssfileid");
        blkContainer.AddButton(eWare.Button("Add Contact", "new.gif", sContactAction));

        sAddressInfoAction = eWareUrl("PRSSFile/PRSSAddressInfo.asp") + "&prss_ssfileid="+ recSSFile("prss_ssfileid");
        blkContainer.AddButton(eWare.Button("View Party Details", "new.gif\" id=\"btnViewPartyDetails", sAddressInfoAction));
    }
    //blkContainer.CheckLocks = false;

    // Check if thePACADeadlineDate is within 31 days
    if (eWare.Mode == View && !isEmpty(recSSFile("prss_pacadeadlinedate")))
    {
        var blkBanners = eWare.GetBlock('content');
        var dtPACA = new Date(recSSFile("prss_pacadeadlinedate"));
        var dtTarget = new Date();
        dtTarget.setDate(dtTarget.getDate()+31);    
        if (dtTarget > dtPACA)
        {
            if ((recSSFile("prss_ClassificationType") == "SBP") ||
                (recSSFile("prss_ClassificationType") == "BSP")) { 
                var sInnerMsg = "<tr><td colspan=\"4\">Approximate PACA Deadline is within 31 days.</td></tr>";
                sBannerMsg = "<table width=\"100%\" cellspacing=0 class=\"MessageContent\">" + sInnerMsg + "</table> ";
                blkBanners.contents = sBannerMsg;
                blkContainer.AddBlock(blkBanners);
            }
        }
    }        
    blkContainer.AddBlock(blkMain);
    
    if (eWare.Mode == View) {
    
        if (isUserInGroup(sSecurityGroups )) {
            var sChangeBlock =  "<table><tr id=\"trChange2\"><td><a class=\"ButtonItem\" href=\"javascript:document.EntryForm.action='" + sSummaryAction + "&RoA=RoA" + "';document.EntryForm.submit();\"></td><td>&nbsp;</td><td><img src=\"/crm/Themes/img/default/Buttons/edit.gif\" border=\"0\" align=\"MIDDLE\"></a><a class=\"ButtonItem\" href=\"javascript:document.EntryForm.action='" + sSummaryAction + "&RoA=RoA" + "';document.EntryForm.submit();\">Change</a></td></tr></table>";
            var blkChange = eWare.GetBlock('content');
            blkChange.contents = sChangeBlock;
            blkContainer.AddBlock(blkChange);
        }

        var sPrintBlock =  "<table><tr id=\"trPrint\"><td><a class=\"ButtonItem\" href=\"\"></td><td>&nbsp;</td><td><a href=\"javascript:printPage();\" class=\"js-print-link\"><img src=\"/crm/Themes/img/default/Buttons/print.gif\" border=\"0\" align=\"MIDDLE\"></a><a class=\"ButtonItem\" href=\"javascript:printPage();\" class=\"js-print-link\">Print</a></td></tr></table>";
        var blkPrint = eWare.GetBlock('content');
        blkPrint.contents = sPrintBlock;
        blkContainer.AddBlock(blkPrint);
    }
    
    eWare.AddContent(blkContainer.Execute(recSSFile));
    
    if (eWare.Mode == View || eWare.Mode == Edit)
    {
        Response.Write("\n<script type=\"text/javascript\">");
        prss_PRCoAssistanceFeeType = recSSFile("prss_PRCoAssistanceFeeType");
        if (isEmpty(prss_PRCoAssistanceFeeType))
            prss_PRCoAssistanceFeeType = 1;
            
        prss_PRCoAssistanceFeePct = recSSFile("prss_PRCoAssistanceFeePct");
        if (isEmpty(prss_PRCoAssistanceFeePct))
            prss_PRCoAssistanceFeePct = "0";
            
        prss_PRCoAssistanceFee = recSSFile("prss_PRCoAssistanceFee");
        if (isEmpty(prss_PRCoAssistanceFee))
            prss_PRCoAssistanceFee = "0.00";
            
        Response.Write("\nprss_PRCoAssistanceFeeType=\"" + prss_PRCoAssistanceFeeType + "\"");
        Response.Write("\nprss_PRCoAssistanceFeePct=" + prss_PRCoAssistanceFeePct + ";");
        Response.Write("\nprss_PRCoAssistanceFee=" + prss_PRCoAssistanceFee + ";");

        if (szMessage != null) {
            Response.Write(" \nalert('" + szMessage + "');\n");
        }

        Response.Write("\n</script>");
    }
    
    if (eWare.Mode == Save) 
    {
        if (bNew)
            sSummaryAction = eWare.Url("PRSSFile/PRSSFile.asp")+ "&prss_ssfileid="+ recSSFile("prss_ssfileid");
        Response.Redirect(sSummaryAction);
        return;
    }
    
    if (eWare.Mode == Edit) 
    {
        // hide the tabs
        Response.Write(eWare.GetPage('Company'));

        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI() {");
        Response.Write("\n        userlogon='"+ recUser("user_logon") + "';");
        Response.Write("\n        Mode="+ eWare.Mode+ ";");
        Response.Write("\n        initializePage();\n");

        if (szRoA == "RoA") {
            Response.Write("\n        var myDiv = $(\"#EWARE_MID\");\n");
            Response.Write("\n        myDiv.animate({ scrollTop: myDiv.prop('scrollHeight') - myDiv.height() }, 10);\n");
            //Response.Write("\n        $(\"[name='prss_recordofactivity']\").focus();\n");
            Response.Write("\n        CKEDITOR.instances['prss_recordofactivity'].focus();\n");
        }

        Response.Write("        document.getElementById('prss_initialamountowed_CID').style.display = 'none';\n");
        Response.Write("        document.getElementById('prss_amountprcocollected_CID').style.display = 'none';\n");
        Response.Write("        document.getElementById('prss_amountprcoinvoiced_CID').style.display = 'none';\n");

        Response.Write("\n        AppendCell('_Captprss_classificationtype', '&nbsp;'); " ); 

        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");
    }
    else
    {
        Response.Write(eWare.GetPage('PRSSFile'));
        sSentToPlanTag = "<span id=\"_CaptReferredToPlan\" class=\"VIEWBOXCAPTION\">Referred To PLAN:</span><br/><span id=_Datareferredtoplan class=\"VIEWBOX\" >";
        if (isEmpty(recSSFile("prss_FileSentToPLANDate")))
            sSentToPlanTag += "No";
        else
            sSentToPlanTag += "Yes";
        sSentToPlanTag += "</span>";
        
        Response.Write("\n<script type=\"text/javascript\" >");
        Response.Write("\n    function initBBSI() {");
        Response.Write("\n        AppendCell('_Captprss_classificationtype', '" + sSentToPlanTag + "'); " ); 
        
        Response.Write(sInitializeTasks);
        // these items may be populated or empty based upon the selected companies
        Response.Write(sClaimantContactTag);
        Response.Write(sRespondentContactTag);
        Response.Write(s3rdPartyContactTag);
        
        Response.Write("\n        AppendRow('_HIDDENprss_recordofactivity', 'trChange2', true);");
        Response.Write("\n        AppendRow('Button_ViewPartyDetails', 'trPrint', false);");

        Response.Write("\n        replaceSpecialCharacters_textarea('_Dataprss_issuedescription');");
        Response.Write("\n        replaceSpecialCharacters_textarea('_Dataprss_publishedissuedesc');");
        Response.Write("\n        replaceSpecialCharacters_textarea('_Dataprss_statusdescription');");
        Response.Write("\n        replaceSpecialCharacters_textarea('_Dataprss_publishednotes');");
        Response.Write("\n        replaceSpecialCharacters_textarea('_Dataprss_workingassessment');");
        Response.Write("\n        replaceSpecialCharacters_textarea('_Dataprss_recordofactivity');");
                
        Response.Write("\n        initializePage();");
        Response.Write("\n    }");
        
        //Response.Write("\n    function initPrint() {");
        //Response.Write("\n      $('.js-print-link').on('click', function () {");
        //Response.Write("\n          $.print('#COLSDIV');");
        //Response.Write("\n      });");  // Fork https://github.com/sathvikp/jQuery.print for the full list of options
        //Response.Write("\n    }");

        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");

    }
    if (sKey0 == "1")
    {
    %>
<!-- #include file ="../PRCompany/CompanyFooters.asp" -->
<%
    }
}

function setupPrimaryContact(sTypeValue, companyid)
{
    sType = new String(sTypeValue)

    sResult = "";
    sContactFields = "";
    nCount = 0;
    if (!isEmpty(companyid)){
        recContact =eWare.FindRecord("PRSSContact", "prssc_SSFileId="+prss_ssfileid+ " and prssc_CompanyId="+companyid);
        nCount = recContact.RecordCount;
        while (!recContact.eof)
        {
            if (recContact("prssc_IsPrimary") == "Y")
                break;
            recContact.NextRecord();
        }
        if (!recContact.eof){
            sContactNotes = "";
            if (!isEmpty(recContact("prssc_ContactNotes")))
            {
                sContactNotes += recContact("prssc_ContactNotes");
                sContactFields = "<div style=\"display:none\"><table ><tr id=\"_tr" + sType + "ContactNotes\">"+
                    "<td colspan=\"4\" class=\"VIEWBOX\" valign=\"TOP\" ><span class=\"VIEWBOXCAPTION\">&nbsp;&nbsp;Contact Notes:</span> <span class=\"VIEWBOX\">"+ sContactNotes + "</span>"+
                    "</td></tr></table></div>";     
                Response.Write(sContactFields );
                sResult += "\n    AppendRow(\"_Captprss_" + sType.toLowerCase() + "companyid\", \"_tr" + sType + "ContactNotes\"); "  
            }

            sContact = recContact("prssc_ContactAttn");
            if (!isEmpty(recContact("prssc_Telephone")))
                sContact += "&nbsp;&nbsp;(P)&nbsp;" + recContact("prssc_Telephone");

            if (!isEmpty(recContact("prssc_Fax")))
                sContact += "&nbsp;&nbsp;(F)&nbsp;" + recContact("prssc_Fax");

            if (!isEmpty(recContact("prssc_Email")))
            {
                recSSFile = eWare.FindRecord("PRSSFile", "prss_ssfileid="+ prss_ssfileid);
                if(recSSFile("prss_Type") != "CC")
                    sContact += "&nbsp;&nbsp;<a href=\"mailto:" + recContact("prssc_Email") + "\">" + recContact("prssc_Email") + "</a>";
            }

            sPrimaryContactCaption = "Primary Contact" + (nCount>1 ? " (1 of " + nCount+ "):" : ":");
            sContactFields = "<div style=\"display:none\"><table ><tr id=\"_tr" + sType + "Contact\">"+
                "<td colspan=\"4\" class=\"VIEWBOX\" valign=\"TOP\" ><span class=\"VIEWBOXCAPTION\">&nbsp;&nbsp;"+ sPrimaryContactCaption +"</span> <span class=\"VIEWBOX\">"+ sContact + "</span>"+
                "</td></tr></table></div>";     
            Response.Write(sContactFields);

            sResult += "\n    AppendRow(\"_Captprss_" + sType.toLowerCase() + "companyid\", \"_tr" + sType + "Contact\"); "  
        }
    }
    return sResult;
}        
%>