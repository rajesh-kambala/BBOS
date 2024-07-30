<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="CompanyARAgingHeader.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2023

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
function doPage()
{
    //bDebug = true;
    DEBUG (sURL);
    
    // because Sage listing are the primary source prior to this
    // page's navigation, comp_companyid is passed but key1 is never set.
    // after 2023 CRM upgrade, key0 was also an issue
    // This is problematic when the user clicks another tab or leaves this
    // screen by using anything but the action buttons on the right side.
    
    var sNewURL = sURL;
    if (sURL.indexOf("Key0=") == -1)
        sNewURL = changeKey(sURL, "Key0", "1");
    if (sURL.indexOf("Key1=") == -1)
        sNewURL = changeKey(sURL, "Key1", comp_companyid);
    if(sNewURL != sURL)
    {
        Response.Redirect(sNewURL);
        return;
    }
    
    if (eWare.Mode == Clear) {
        Session("TradeReportListing_CompanyID") = 0;
        var sNewURL = changeKey(sURL, "em", "2");
        Response.Redirect(sNewURL);
        return;
    }

    var sSecurityGroups = "1,2,3,4,5,6,8,9,10";

    blkContainer = eWare.GetBlock('container');
    blkContainer.CheckLocks = false;
    blkContainer.DisplayButton(Button_Default) = false;

    var blkGeneralContent = eWare.GetBlock("content");
    blkGeneralContent.Contents += "<link rel=\"stylesheet\" href=\"../../prco.css\">\n";
    blkGeneralContent.Contents += "<link rel=\"stylesheet\" href=\"../../prco_compat.css\">\n";
    blkContainer.AddBlock(blkGeneralContent);

    var sInitialized = getFormValue("hdnInitialized");
    var sDefaultStartDate = "";
    if (isEmpty(sInitialized)){
        sInitialized = "0";
        // get the date for three months ago
        dtNow = new Date();
        dt3MonthsAgo = new Date(dtNow.getYear(),dtNow.getMonth() - 3,dtNow.getDate());
        sDefaultStartDate = ((dt3MonthsAgo.getMonth()+1) + "/" + (dt3MonthsAgo.getDate()) +  "/" + dt3MonthsAgo.getFullYear());
    }
    DEBUG("Initialized: " + sInitialized);
    if (sInitialized == "0"){
        eWare.Mode = Edit;
        // we need to put hiddenorderby and hiddensortorder on the form so they can be set
        // but we do not want to add the PRTradeReportOnGrid.
        blkContents = eWare.GetBlock("content");
        sContents = "<input type=\"hidden\" name=\"HIDDENORDERBY\" value=\"prtr_Date\" >";
        sContents += "<input type=\"hidden\" name=\"HIDDENORDERBYDESC\" value=\"TRUE\">";
        sContents += "<input type=\"hidden\" name=\"hdnInitialized\" value=\"1\">";
        blkContents.contents = sContents;
        blkContainer.AddBlock(blkContents);
        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage('Company'));
        
        %>
            <script type="text/javascript">
                function initBBSI() 
                {
                    document.EntryForm.submit();
                }
                if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }
            </script>
        <%

        return;

    }
    DEBUG("Loading Page: eware.mode: " + eWare.Mode);
    // Add a field to the submitted screen to tell us we have initialized this page
    // Don't show any blocks unless we are initialized
%>
        <!-- #include file ="PRCompanyTradeInclude.asp" --> 
<%

    blkInitialized = eWare.GetBlock("content");
    blkInitialized.contents = "\n<input type=\"hidden\" name=\"hdnInitialized\" value=\"" + sInitialized + "\">\n";
    blkContainer.AddBlock(blkInitialized);
    
    var blkTradeReportHeader = eWare.GetBlock('content');
    var sMsg = "\n<link rel=\"stylesheet\" href=\"/CRM/prco.css\">";
    sMsg += "\n<link rel=\"stylesheet\" href=\"/CRM/prco_compat.css\">\n";
    sMsg += "<table width=\"100%\" class=\"WarningContent\"><tr><td>You are currently viewing trade reports ON " + recCompany("comp_Name") + "</td></tr></table>\n";

    var sARAgingHeader = getARAgingHeader();
    if (sARAgingHeader != "") {
        sMsg += "<table width=\"100%\" cellspacing=0 class=\"MessageContent\">" + sARAgingHeader + "</table>\n";
    }
    blkTradeReportHeader.contents = sMsg;
    
    blkContainer.AddBlock(blkTradeReportHeader);

    if (eWare.Mode == View || eWare.Mode == Find)
    {
        //DumpFormValues();
        var blkIncludes = eWare.GetBlock("content");
        //blkIncludes.contents += "\n<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>\n";
        blkIncludes.contents += "<script type=\"text/javascript\" src=\"PRCompanyTradeReportInclude.js\"></script>\n";
        blkContainer.AddBlock(blkIncludes);

        eWare.Mode = Edit;

        var blkTradeActivityNotes = eWare.GetBlock("PRCompanyNotes");
        blkTradeActivityNotes.Title="Trade Activity Notes";
        entry = blkTradeActivityNotes.GetEntry("prcomnot_CompanyNoteNote");
        entry.Caption = "Trade Activity Note:";
        entry.ReadOnly = true;
        
        var recCompanyNote = eWare.FindRecord("PRCompanyNote", "prcomnot_CompanyId=" + comp_companyid + " AND prcomnot_CompanyNoteType='TRADEACTIVITY'");
        blkTradeActivityNotes.ArgObj = recCompanyNote;
        blkContainer.AddBlock(blkTradeActivityNotes);

        //blkFilter is created in PRCompanyTradeInclude.asp
        blkFilter.Width = "95%";
        blkContainer.AddBlock(blkFilter);    
        
        if (!isEmpty(sIncludeBranches)) {
            sWhere = "comp_PRHQID="+comp_companyid ;
        } else {
            sWhere = "prtr_subjectid="+comp_companyid ;
        }

        if (!isEmpty(sFormStartDate))
            sWhere += " AND prtr_Date >= " + sDBStartDate;
        if (!isEmpty(sFormEndDate))
            sWhere += " AND prtr_Date <= " + sDBEndDate;

        if (comp_PRIndustryType != "") {
            sWhere += " AND comp_PRIndustryType='"+comp_PRIndustryType + "'";
        }
        if (sDBException != "NULL")
        {
            if (sDBException == "Y")
                sWhere += " AND prtr_Exception = '" + sDBException + "'";
            else
                sWhere += " AND prtr_Exception is NULL ";
        }        
        if (sDBDisputeInvolved != "NULL")
        {
            if (sDBDisputeInvolved == "Y")
                sWhere += " AND prtr_DisputeInvolved = '" + sDBDisputeInvolved + "'";
            else
                sWhere += " AND prtr_DisputeInvolved  is NULL ";
        }        
        if (sDBDuplicate != "")
        {
            if (sDBDuplicate == "Y")
                sWhere += " AND prtr_Duplicate = 'Y' ";
            else
                sWhere += " AND (prtr_Duplicate IS NULL or prtr_Duplicate = 'N') ";
        }        
        if (sDBClassListForInClause != "")
        {
            sWhere += " AND " +
             " prtr_ResponderId in " +
             " (select distinct prtr_ResponderId from  " +
             "    (select prtr_ResponderId, highest_level = Left(prcl_Path, charindex(',',prcl_Path)-1) " + 
             "     from PRTradeReport WITH (NOLOCK) " + 
	         "     LEFT OUTER JOIN PRCompanyClassification WITH (NOLOCK) ON prc2_CompanyId = prtr_ResponderId " +
	         "     LEFT OUTER JOIN PRClassification WITH (NOLOCK) ON prc2_ClassificationId = prcl_classificationId " +
             "     where prtr_SubjectId = " + comp_companyid + " ) ATable " +
             "  WHERE highest_level in (" + sDBClassListForInClause + ") " +
             " ) " ;
        }

        // This check must be done last, as all of the other criteria
        // is applied to the sub-query used to determine the most recent
        // trade report record by responder.
        //if (sMostRecentOnly != "") {
        if (!isEmpty(sMostRecentOnly)) {
            sWhere = "prtr_TradeReportID IN (" +
	                     "SELECT TradeReportID FROM (" +
		                    "SELECT prtr_ResponderID, max(prtr_TradeReportID) As TradeReportID " +
		                     "FROM vPRTradeReportOn " +
		                     "WHERE " + sWhere + " "  +
		                  "GROUP BY prtr_ResponderID) T1) ";
        }

        recTradeReports = null;
        recTradeReports = eWare.FindRecord("vPRTradeReportOn", sWhere);
        //Response.Write("<br/>Where Clause:" + sWhere);
        //Response.End();
    %>	
    <!-- #include file ="PRCompanyTradeReportAnalysisInclude.asp" -->
    <%
        // add the listing block
        blkList = eWare.GetBlock("PRTradeReportOnGrid");
        blkList.ArgObj = recTradeReports;
        entry=blkList.GetGridCol("prtr_Date");
        entry.OrderByDesc = true;
          
        if (recCompany.comp_PRIndustryType == "L") {
                blkList.DeleteGridCol("prtr_HighCredit");
        } else {
                blkList.DeleteGridCol("prtr_HighCreditL");
        }


        blkContainer.AddBlock(blkList);    


        // Show the buttons
        blkContainer.AddButton(eWare.Button("Show Analysis", "Showanalysis.gif", "javascript:showAnalysis();"));
        blkContainer.AddButton(eWare.Button("Hide Analysis", "Showanalysis.gif", "javascript:hideAnalysis();"));


        tabContext = "&T=Company&Capt=Trade+Activity&comp_companyid=" + comp_companyid;

        if (isUserInGroup(sSecurityGroups))
        {
            blkContainer.AddButton(eWare.Button("Change Notes", "edit.gif", eWare.URL("PRCompany/PRCompanyNotes.asp") + "&notetype=TRADEACTIVITY"));

            if (recCompany.comp_PRLocalSource !=  "Y") {
                sNewUrl = eWare.URL("PRCompany/PRCompanyTradeReport.asp") + "&prtr_SubjectId=" + comp_companyid + tabContext;
                blkContainer.AddButton(eWare.Button("New Trade Report", "new.gif", sNewUrl));
            }
        }
        
        blkContainer.AddButton("<b>View All:</b>"); 
        blkContainer.AddButton(eWare.Button("Trade&nbsp;Reports (By)", "edit.gif", eWare.URL("PRCompany/PRCompanyTradeReportByListing.asp") + tabContext));

        if (recCompany.comp_PRLocalSource !=  "Y") {
            blkContainer.AddButton(eWare.Button("A/R&nbsp;Aging (On) 2 Yrs", "edit.gif", eWare.URL("PRCompany/PRCompanyARAgingOnListing.asp") + tabContext));

            // Defect 6931
            var sARAging5YrsSQL = "SELECT dbo.ufn_GetReportURL('ArchiveARAging') As ReportURL";
            recQuery = eWare.CreateQueryObj(sARAging5YrsSQL);
            recQuery.SelectSql();
            var szReportURL = recQuery("ReportURL") + "&CompanyID=" + comp_companyid + "&rc:Parameters=false"; 
            blkContainer.AddButton(eWare.Button("A/R&nbsp;Aging (On) 5 Yrs","componentpreview.gif", "javascript:viewReport('" + szReportURL + "');"));

            blkContainer.AddButton(eWare.Button("A/R&nbsp;Aging (By)", "edit.gif", eWare.URL("PRCompany/PRCompanyARAgingByListing.asp") + tabContext));
            blkContainer.AddButton(eWare.Button("TES&nbsp;Forms (Sent&nbsp;About)", "edit.gif", eWare.URL("PRCompany/PRCompanyTESAboutListing.asp") + tabContext));
        }

        blkContainer.AddButton(eWare.Button("TES&nbsp;Forms (Sent&nbsp;To)", "edit.gif", eWare.URL("PRCompany/PRCompanyTESToListing.asp") + tabContext));

        blkContainer.AddButton(eWare.Button("Exceptions", "edit.gif", eWare.URL("PRCompany/PRCompanyExceptionListing.asp") + tabContext));
        if (recCompany.comp_PRLocalSource !=  "Y") {
            blkContainer.AddButton(eWare.Button("Verbal Investigations", "Continue.gif", eWare.URL("PRTES/PRVerbalInvestigationList.asp") + tabContext));
        }

        blkContainer.AddButton(eWare.Button("Send Email TES Form", "edit.gif", eWare.URL("PRTES/PRTESSendEmail.asp") + tabContext));

        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage('Company'));
        
        sCheckHideAnalysis = "";
        sHideAnalysis = String(Request.Form.Item("chk_hideanalysis"));
        if (sHideAnalysis != null && sHideAnalysis == "on")
            sCheckHideAnalysis = "CHECKED";
        sSearchClassContent = "<input type=\"CHECKBOX\" style=\"display:none;\"" + sCheckHideAnalysis+ " id=\"chk_hideanalysis\" name=\"chk_hideanalysis\">" 
            + sSearchClassContent 

	    Response.Write("\n<table><tr id=\"tr_tblSearchClassOptions\"><td colspan=\"2\" rowspan=\"8\" valign=\"TOP\" align=\"LEFT\" ID=\"td_tblSearchClassOptions\">" + sSearchClassContent + "</td></tr></table>");
	    Response.Write("\n<table><tr><td width=\"33%\" align=\"LEFT\" valign=\"top\" ID=\"td_tblSearchDateRange\">" + szDateRange + "</td></tr></table>");
        Response.Write(szDuplicateSelect);
        Response.Write(szMostRecentOnly);
        if (recCompany("comp_PRType") == "H") {
            Response.Write(szIncludeBranches);
        }

        %>
            <script type="text/javascript" >
                function initBBSI() 
                {
                    // remove this option in lieu of the existing Date Range: option which users really like
                    RemoveDropdownItemByName("DateTimeModesprtr_date", "Relative");
                    RemoveDropdownItemByName("_exceptionselect", "--None--");
                    RemoveDropdownItemByName("_disputeinvolvedselect", "--None--");
                    RemoveDropdownItemByName("comp_prindustrytype", "--None--");
        <%            
                    if (sDBException != "NULL")
                        Response.Write("SelectDropdownItemByValue('_ExceptionSelect', '" + sDBException + "');\n");

                    if (sDBDisputeInvolved != "NULL")
                        Response.Write("SelectDropdownItemByValue('_DisputeInvolvedSelect', '"+  sDBDisputeInvolved + "');\n");

                    if (sCheckHideAnalysis=="" )
                        Response.Write("                showAnalysis();\n");
                    else
                        Response.Write("                hideAnalysis();\n");
                        
                    Response.Write("SelectDropdownItemByValue('comp_prindustrytype', '"+  comp_PRIndustryType + "');\n");                        
        %>
                    document.getElementById("prtr_date_start").value = "<% =sFormStartDate %>";
                    document.getElementById("prtr_date_end").value = "<% =sFormEndDate %>";

                    AppendCell("_Captprtr_date", "td_tblSearchDateRange");
                    AppendRow("_Captcomp_prindustrytype", "tr_tblSearchClassOptions");
                    AppendRow("_disputeinvolvedselect", "td_DuplicateSelect");
                    
                    AppendRow("td_DuplicateSelect", "td_MostRecentOnly");
                    
<%                  if (recCompany("comp_PRType") == "H") { 
                        Response.Write("                AppendRow('td_MostRecentOnly', 'td_IncludeBranches');");
                    }
%>
                    toggleDateFieldsForRange(true);
                    document.getElementById("_Dataprcomnot_companynotenote").className = "VIEWBOX";
                    
                }
                if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }
            </script>
        <%
        }
    %>
    
<%
}
doPage();
%>
<!-- #include file="CompanyFooters.asp" -->
