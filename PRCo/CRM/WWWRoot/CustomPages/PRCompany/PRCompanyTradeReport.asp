<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2020

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

<%

    doPage();

function doPage() {
    var sSecurityGroups = "1,2,3,10";

    blkContainer = eWare.GetBlock('container');
    blkContainer.CheckLocks = false;
    blkContainer.DisplayButton(Button_Default) = false;

	var sEntityName = "PRTradeReport";
    var sListingPage = "PRCompany/PRCompanyTradeReportByListing.asp";
    var sSummaryPage = "PRCompany/PRCompanyTradeReport.asp";
    // Assume this is a Trade Report By entry
    var sEntityCompanyIdName = "prtr_ResponderId";
    // indicates that this is a Trade Report By report
    var bIsTRBy = true;
    var sEntityIdName = "prtr_TradeReportId";

    var Id = getIdValue(sEntityIdName);
    // indicate that this is new
    if (Id == "-1" )
    {
        var bNew = true;
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }
    recTradeReport = eWare.FindRecord(sEntityName, sEntityIdName + "= " + Id);

    var prtr_responderid = getIdValue("prtr_ResponderId");
    if (prtr_responderid == -1)
    {
        prtr_responderid = recTradeReport("prtr_ResponderId");
    }
    var prtr_subjectid = getIdValue("prtr_SubjectId");
    if (prtr_subjectid == -1) {
        prtr_subjectid = recTradeReport("prtr_SubjectId");
    }

    if (Request("IsVI") == "1") {
        prtr_responderid = Session("VITESResponder");
        prtr_subjectid = comp_companyid;
    } 

    /*
    Response.Write("<br>ResponderId: '" + prtr_responderid + "'");
    Response.Write("<br>SubjectId: '" + prtr_subjectid + "'");
    Response.Write("<br>CompanyId: '" + comp_companyid + "'");
    //return;
    */

    // if the subjectId is the current company we're viewing, we viewing TR On listing
    recSubjectHQ = eWare.FindRecord("company","comp_companyid=" + prtr_subjectid);
    if (recSubjectHQ("comp_PRHQID") ==  recCompany("comp_PRHQID"))
    {
        // this should be a Trade Report On
        sEntityCompanyIdName = "prtr_SubjectId";
        sListingPage = "PRCompany/PRCompanyTradeActivityListing.asp";
        bIsTRBy = false;
    }

    sListingAction = eWare.Url(sListingPage)+ "&" + sEntityCompanyIdName + "=" + comp_companyid;
    sSummaryAction = eWare.Url(sSummaryPage)+ "&" + sEntityIdName + "="+ Id;

    if (Request("IsVI") == "1") {
        sListingAction = eWare.Url("PRTES/PRVerbalInvestigationCallQueueDetail.asp") + "&prtesr_ResponderCompanyID=" + Session("VITESResponder");
    } 


    blkEntry=eWare.GetBlock("PRTradeReportNewEntry");
    entrySubject = blkEntry.GetEntry("prtr_SubjectId");
    entryResponder = blkEntry.GetEntry("prtr_ResponderId");
    if (bIsTRBy == true)
        blkEntry.Title= "Trade Report By " + recCompany("comp_Name");
    else
        blkEntry.Title= "Trade Report On " + recCompany("comp_Name");
    
    entrySubject.Hidden = !bIsTRBy;
    entryResponder.Hidden = bIsTRBy;
    
    if ((Request("IsVI") == "1")  ||
        (Request("IsSSFile") == "1")) {
        entryResponder.DefaultValue = prtr_responderid;
        entrySubject.DefaultValue = prtr_subjectid;
    }
    
    blkEntry.GetEntry("prtr_Date").DefaultValue = getDBDateTime();

    if (recCompany.comp_PRIndustryType == "L") {
        blkEntry.GetEntry("prtr_HighCredit").LookupFamily = "prtr_HighCreditL";
    } 
    
    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    Response.Write("<script type=\"text/javascript\" src=\"PRCompanyTradeReportInclude.js\"></script>");

    // set up client-side variable to indicate if this is a "BY" or "ON" trade report
    Response.Write("<script type=\"text/javascript\">");
    Response.Write("    var bIsTRBy = " + bIsTRBy+ ";");
    Response.Write("    var sGlobalCompanyId = \"" + comp_companyid + "\";");
    Response.Write("</script>");



    // based upon the mode determine the buttons and actions
    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        //DumpFormValues();
        if (bNew)
        {
	        recTradeReport = eWare.CreateRecord(sEntityName);
			recTradeReport.item(sEntityCompanyIdName) = comp_companyid;
			recTradeReport.prtr_ResponseSource = 'M';
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        }
        else
        {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
        }
        
        prtr_integrityid = Request.Form.Item("prtr_integrityid");
		if (!isEmpty(prtr_integrityid) )
			recTradeReport.prtr_integrityid = prtr_integrityid;
        prtr_payratingid = Request.Form.Item("prtr_payratingid");
		if (!isEmpty(prtr_payratingid) )
			recTradeReport.prtr_payratingid = prtr_payratingid;

    	blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));

    }
    else if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the record
        sql = "DELETE FROM " + sEntityName + " WHERE " + sEntityIdName + "="+ Id;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
    }
    else // view mode
    {
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));

        if (isUserInGroup(sSecurityGroups))
        {
            // do not know if users are allowed to delete trade reports
            sDeleteUrl = changeKey(sURL, "em", "3");
            blkContainer.AddButton(eWare.Button("Delete", "delete.gif", 
                "javascript:if (confirm('Are you sure you want to permanently delete this trade report?')) {" + 
                "location.href='"+sDeleteUrl+"';}"));

            blkContainer.AddButton(eWare.Button("Make Correction","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
        }
    }
    blkContainer.CheckLocks = false; 

    blkContainer.AddBlock(blkEntry);
    
    blkRelated = eWare.GetBlock("content");
    sSQL = "SELECT relatedcompanylist = dbo.ufn_GetRelatedCompaniesList(" + comp_companyid + ") " ;

    recRelated = eWare.CreateQueryObj(sSQL);
    recRelated.SelectSQL();
    sRelated = "";
    if (!recRelated.eof)
        sRelated = recRelated("relatedcompanylist");
    if (isEmpty(sRelated))
        sRelated = "";    
    blkRelated.contents = "<input type=hidden id=hdn_relatedcompanylist value="+ sRelated+">";
    blkContainer.AddBlock(blkRelated);
    eWare.AddContent(blkContainer.Execute(recTradeReport)); 
    
    if (eWare.Mode == Save) 
    {
	    if (bNew) {

            // If this is for a Verbal Investigation, then make sure we set our
            // TES Request flags and associate the appropriate records	    
	        if (Request("IsVI") == "1") {
	        
	            sSQL = "SELECT prtesr_TESRequestID FROM PRTESRequest WITH (NOLOCK) INNER JOIN PRVerbalInvestigation WITH (NOLOCK) ON prtesr_VerbalInvestigationID = prvi_VerbalInvestigationID WHERE prvi_Status = 'O' AND prtesr_SubjectCompanyID = " + prtr_subjectid + " AND prtesr_ResponderCompanyID = " + prtr_responderid + " AND prtesr_SentMethod = 'VI' AND prtesr_Received IS NULL";
                var recPRTESRequest = eWare.CreateQueryObj(sSQL);
                recPRTESRequest.SelectSQL();
                
                if (!recPRTESRequest.eof) {
                    var PRTESRequestID = recPRTESRequest("prtesr_TESRequestID");
            
                    sSQL = "UPDATE PRTESRequest SET prtesr_Received='Y', prtesr_ReceivedMethod = 'V', prtesr_ReceivedDateTime = GETDATE() WHERE prtesr_TESRequestID=" + PRTESRequestID;
		            recUpdatePRTESRequest = eWare.CreateQueryObj(sSQL);
		            recUpdatePRTESRequest.ExecSql();

                    recTradeReport.prtr_TESRequestID = PRTESRequestID;
                    recTradeReport.SaveChanges();
                }
	        }

            if (Request("IsSSFile") == "1") {
                recTradeReport.prtr_SSFileID = getIdValue("prss_ssfileid");
                recTradeReport.SaveChanges();

                var recSSFile = eWare.FindRecord("PRSSFile", "prss_ssfileid="+ getIdValue("prss_ssfileid"));
                recSSFile.prss_ClaimantTradeReportDate = getDBDateTime(new Date());
                recSSFile.SaveChanges();

                Response.Redirect(eWare.Url("PRSSFile/PRSSFile.asp")+ "&prss_ssfileid=" + getIdValue("prss_ssfileid"));
            }

	        Response.Redirect(sListingAction);
	    } else
	        Response.Redirect(sSummaryAction);
    }
    else  if (eWare.Mode == Edit) 
    {
        // hide the tabs
        Response.Write(eWare.GetPage('Company'));
    }
    else
        Response.Write(eWare.GetPage());

    if (eWare.Mode != Save) 
    {

%>
<!-- #include file="TradeReportRatingsInclude.asp" -->

<%
        Response.Write("\n<script type=text/javascript >");
        Response.Write("\n    document.body.onload=function() {");
        Response.Write("\n        AppendCell(\"_Captprtr_highcredit\", \"td_prtr_integrityid\");");
        Response.Write("\n        AppendCell(\"_Captprtr_integrityid\", \"td_prtr_payratingid\");");
        
        if ((eWare.Mode == Edit)  &&
            (Request("IsVI") == "1")) {
            Response.Write("\n        document.getElementById('prtr_subjectid').value='" + prtr_subjectid + "';");
        }

        if(eWare.Mode == Edit && recTradeReport("prtr_HighCredit") == "F")
        {
            //Leave HighCredit values alone
        }
        else
        {
            //Remove F (Over 250M) from list
            Response.Write("\n     RemoveDropdownItemByValue('prtr_highcredit', 'F');");
        }
        
        //Response.Write("\n        LoadComplete('');");        
        Response.Write("\n    }");
        Response.Write("\n</script>");
    }
}
%>

<!-- #include file="CompanyFooters.asp" -->