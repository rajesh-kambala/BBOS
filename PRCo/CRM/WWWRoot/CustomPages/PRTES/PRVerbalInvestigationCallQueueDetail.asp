<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\PRCompany\CompanyARAgingHeader.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2010-2023

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

doPage();

var sCompanyID;
var comp_companyid;

function doPage() {
    sCompanyID = getIdValue("prtesr_ResponderCompanyID");

    // This is the Continue link.  
    // Remove ALL locks and move along...
    if (eWare.Mode == "95") {
        sSQL = "UPDATE PRTESRequest SET prtesr_ProcessedByUserID=NULL FROM PRTESRequest WITH (NOLOCK) INNER JOIN PRVerbalInvestigation WITH (NOLOCK) ON prtesr_VerbalInvestigationID = prvi_VerbalInvestigationID WHERE prtesr_SentMethod = 'VI' AND prtesr_ProcessedByUserID= " + user_userid;
        recUpdatePRTESRequest = eWare.CreateQueryObj(sSQL);
        recUpdatePRTESRequest.ExecSql();
        
        Response.Redirect(eWare.Url("PRTES/PRVerbalInvestigationCallQueue.asp"));
        return;
    }

    // This is Reset Lock to Me
    var sUserMsg = ""
    if (eWare.Mode == "97") {
        sSQL = "UPDATE PRTESRequest SET prtesr_ProcessedByUserID= " + user_userid + " FROM PRTESRequest WITH (NOLOCK) INNER JOIN PRVerbalInvestigation WITH (NOLOCK) ON prtesr_VerbalInvestigationID = prvi_VerbalInvestigationID WHERE prvi_Status = 'O' AND prtesr_ResponderCompanyID = " + sCompanyID + " AND prtesr_SentMethod = 'VI' AND prtesr_Received IS NULL";
        recUpdatePRTESRequest = eWare.CreateQueryObj(sSQL);
        recUpdatePRTESRequest.ExecSql();
        
        sUserMsg = "The lock for this Verbal TES Responder has been reset to you.";
        eWare.Mode = View;
    }

    var blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    

    // Before we really render anything, we need to determine if any of these
    // PRTESRecords are locked.
    var sSQL = "SELECT prtesr_ProcessedByUserID, user_logon, user_FirstName, user_LastName FROM PRTESRequest WITH (NOLOCK) INNER JOIN PRVerbalInvestigation WITH (NOLOCK) ON prtesr_VerbalInvestigationID = prvi_VerbalInvestigationID INNER JOIN Users ON user_userid = prtesr_ProcessedByUserID WHERE prvi_Status = 'O' AND prtesr_ResponderCompanyID = " + sCompanyID + " AND prtesr_SentMethod = 'VI' AND prtesr_Received IS NULL AND prtesr_ProcessedByUserID IS NOT NULL";
    var recPRTESRequest = eWare.CreateQueryObj(sSQL);
    recPRTESRequest.SelectSQL();
    
    // If we didn't find anyone, then lock these records
    // with the current user.
    var bDisplaySwitchLockButton = false;
    if (recPRTESRequest.eof) {
        // First unlock all records that the curent user has locked because
        // they should only have one locked at a time.
        sSQL = "UPDATE PRTESRequest SET prtesr_ProcessedByUserID=NULL FROM PRTESRequest WITH (NOLOCK) INNER JOIN PRVerbalInvestigation WITH (NOLOCK) ON prtesr_VerbalInvestigationID = prvi_VerbalInvestigationID WHERE prtesr_SentMethod = 'VI' AND prtesr_ProcessedByUserID= " + user_userid;
        recUpdatePRTESRequest = eWare.CreateQueryObj(sSQL);
        recUpdatePRTESRequest.ExecSql();

        // Now lock this record.
        sSQL = "UPDATE PRTESRequest SET prtesr_ProcessedByUserID= " + user_userid + " FROM PRTESRequest WITH (NOLOCK) INNER JOIN PRVerbalInvestigation WITH (NOLOCK) ON prtesr_VerbalInvestigationID = prvi_VerbalInvestigationID WHERE prvi_Status = 'O' AND prtesr_ResponderCompanyID = " + sCompanyID + " AND prtesr_SentMethod = 'VI' AND prtesr_Received IS NULL";
        recUpdatePRTESRequest = eWare.CreateQueryObj(sSQL);
        recUpdatePRTESRequest.ExecSql();
    } else {
    
        if (recPRTESRequest("prtesr_ProcessedByUserID") != user_userid) {
            var blkBanners = eWare.GetBlock('content');         
            blkBanners.contents = "<table width=\"100%\" class=\"ErrorContent\"><tr><td>This Verbal TES Responder is currently Locked by " + recPRTESRequest("user_FirstName") + " " + recPRTESRequest("user_LastName") + ".</td></tr></table> ";
            blkContainer.AddBlock(blkBanners);
            
            bDisplaySwitchLockButton = true;
        }
    }


    var blkARAgingHeaderHeader = eWare.GetBlock('content');
    var sMsg = "";

    comp_companyid = sCompanyID;
    var sARAgingHeader = getARAgingHeader();
    if (sARAgingHeader != "") {
        
        sMsg += "<table width=\"100%\" cellspacing=0 class=\"MessageContent\">" + sARAgingHeader + "</table> ";
    }

    blkARAgingHeaderHeader.contents = sMsg;
    blkContainer.AddBlock(blkARAgingHeaderHeader);    

    var recVIResponder = eWare.FindRecord("vPRVIResponder", "comp_CompanyID=" + sCompanyID);
    var blkEntry=eWare.GetBlock("PRVIResponder");
    blkEntry.Title="TES Responder";
    blkEntry.ArgObj = recVIResponder;
    blkContainer.AddBlock(blkEntry);


	var recPhone = eWare.FindRecord("vPRCompanyPhone","plink_RecordID=" + sCompanyID);
    var grdPhone = eWare.GetBlock("CompanyPhoneGrid");
    //grdPhone.DeleteGridCol("phon_companyid");
    grdPhone.DisplayForm=false;
    grdPhone.ArgObj = recPhone;
    grdPhone.PadBottom = false;
    blkContainer.AddBlock(grdPhone);


    var recSubjectCompanies = eWare.FindRecord("vPRTESVISubjectCompanies", "prtesr_ResponderCompanyID=" + sCompanyID);
    var grdSubjectCompaniess=eWare.GetBlock("PRTESVISubjectCompaniesGrid");
    grdSubjectCompaniess.ArgObj = recSubjectCompanies;
    grdSubjectCompaniess.PadBottom = false;
    blkContainer.AddBlock(grdSubjectCompaniess);


    var recCallAttempts = eWare.FindRecord("vPRVICallAttempts", "prtesr_ResponderCompanyID=" + sCompanyID + " AND prvict_CreatedDate >= DATEADD(day, -30, GETDATE())");
    var grdCallAttempts=eWare.GetBlock("PRVICallAttempts");
    grdCallAttempts.ArgObj = recCallAttempts;
    grdCallAttempts.PadBottom = false;
    blkContainer.AddBlock(grdCallAttempts);

    var sTESRequestIDList = "";
    var sSQL = "SELECT prtesr_TESRequestID FROM vPRTESVISubjectCompanies WHERE prtesr_ResponderCompanyID=" + sCompanyID;
    var recSubjectCompanies2 = eWare.CreateQueryObj(sSQL);
    recSubjectCompanies2.SelectSQL();
    while (!recSubjectCompanies2.eof) {
        if (sTESRequestIDList.length > 0) {
            sTESRequestIDList += ",";
        }
        sTESRequestIDList += recSubjectCompanies2("prtesr_TESRequestID");
        recSubjectCompanies2.NextRecord();
    }

    blkContainer.AddButton(eWare.Button("Continue", "Continue.gif", changeKey(sURL, "em", "95") + "&T=Company&Capt=Trade+Activity"));
    blkContainer.AddButton(eWare.Button("Attention Lines", "AddRecToGroup.gif" , eWare.Url("PRCompany/PRCompanyAttentionLine.asp") + "&key0=1&key1=" + sCompanyID + "&T=Company&Capt=Contact+Info"));

    if (recSubjectCompanies.RecordCount > 0) {
        blkContainer.AddButton(eWare.Button("No Response", "Continue.gif", eWare.Url("PRTES/PRVerbalInvestigationCallQueueNoResponse.asp") + "&prtesr_ResponderCompanyID=" + sCompanyID + "&T=Company&Capt=Trade+Activity"));
        var sReturnURL = Server.URLEncode(eWare.URL("PRTES/PRVerbalInvestigationCallQueueDetail.asp") + "&prtesr_ResponderCompanyID=" + sCompanyID);
        blkContainer.AddButton(eWare.Button("Send Email TES Form", "edit.gif", eWare.URL("PRTES/PRTESSendEmail.asp") + "&comp_CompanyID=" + sCompanyID + "&TESIDList=" + sTESRequestIDList + "&ReturnURL=" + sReturnURL + "&T=Company&Capt=Trade+Activity"));
    }
    
    if (bDisplaySwitchLockButton) {
        blkContainer.AddButton(eWare.Button("Switch Lock To Me", "cti_consult.gif", changeKey(sURL, "em", "97")));
    }

    eWare.AddContent(blkContainer.Execute()); 
    Response.Write(eWare.GetPage(''));  
    
    if (sUserMsg != "") {
        Response.Write("<script>alert('" + sUserMsg + "');</script>");
    }

    Session("VITESResponder") = sCompanyID;
}    

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
%>

<script type="text/javascript">
    var oATags = document.getElementsByTagName('a');
    for (var i = 0; i < oATags.length; i++) {

        if (oATags[i].href.indexOf("PRCompanyPhone.asp") > 0) {
            oATags[i].href = oATags[i].href + "&comp_CompanyID=<%=sCompanyID %>";
        }
    }    
</script>