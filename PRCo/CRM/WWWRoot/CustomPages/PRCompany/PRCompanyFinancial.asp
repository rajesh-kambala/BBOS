<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2022

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
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->

<%
    var sSecurityGroups = "1,2,3,10";

    var blkCW = eWare.GetBlock("PRCreditWorthCap");
    blkCW.Title = "Credit Worth Cap";
    blkCW.Mode = View;
    blkCW.ArgObj = recCompany;

    // Build our CreditWorthCap field
    var sInsertString = "<table><tr><td id=\"tdCreditWorthCap\" valign=\"top\">"
    sInsertString = sInsertString + "<span id=\"_Captcomp_prcreditworthcap\" class=\"VIEWBOXCAPTION\">Credit Worth Cap:</span><br/>"

    if ((recCompany.comp_PRCreditWorthCap == null) || (recCompany.comp_PRCreditWorthCap == 0)) {
        szCreditWorth = "-None Selected-";
    } else {
        recCRM = eWare.FindRecord("PRCreditWorthRating","prcw_CreditWorthRatingId=" + recCompany.comp_PRCreditWorthCap);
        szCreditWorth = recCRM.prcw_Name;
    }

    sInsertString = sInsertString + "<span id=\"_Datacomp_prcreditworthcapreason\" class=\"VIEWBOX\">" + szCreditWorth + "</span>";
    sInsertString = sInsertString + "</td></tr></table>";
    Response.Write(sInsertString);

    sInsertString = "AppendCell(\"_Captcomp_prcreditworthcapreason\", \"tdCreditWorthCap\", true);"; 

    lstMain = eWare.GetBlock("PRFinancialGrid");
    var f_value = new String(Request.QueryString("F"));
    if (isEmpty(f_value))
    {
        f_value = "PRCompany/PRCompanySummary.asp";
    }

    if (eWare.Mode > View)
        eWare.Mode = View;

    lstMain.prevURL = eWare.URL(f_value);;
    var recFinancials = eWare.FindRecord('PRFinancial','prfs_CompanyId=' + comp_companyid);
    lstMain.ArgObj = recFinancials;

    blkContainer = eWare.GetBlock('container');

    if (recCompany.comp_PRConfidentialFS == "2") {
        Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");

        var blkBanners = eWare.GetBlock('content');
        var sBannerMsg = "\n\n<table width=\"100%\"><tr><td width=\"100%\" align=\"center\">\n";
		sBannerMsg += "<table class=\"MessageContent\" align=\"center>\"\n";
        sBannerMsg += "<tr><td>Financial figures for this company have been marked Confidential.</td></tr>";
		sBannerMsg += "</table>\n";
		sBannerMsg += "</td></tr></table>\n\n";
		blkBanners.contents = sBannerMsg;
		blkContainer.AddBlock(blkBanners);
    }

    blkContainer.AddBlock(blkCW);

    var blkfinancialNotes = eWare.GetBlock("PRCompanyNotes");
    blkfinancialNotes.Title="Financial Statements Analysis Notes";
    entry = blkfinancialNotes.GetEntry("prcomnot_CompanyNoteNote");
    entry.Caption = "FS Analysis Notes:";
    entry.ReadOnly = true;

    var recCompanyNote = eWare.FindRecord("PRCompanyNote", "prcomnot_CompanyId=" + comp_companyid + " AND prcomnot_CompanyNoteType='FINANCIAL'");
    blkfinancialNotes.ArgObj = recCompanyNote;
    blkContainer.AddBlock(blkfinancialNotes);

    blkContainer.AddBlock(lstMain);
    blkContainer.DisplayButton(Button_Default) = false;

    blkContainer.AddButton(eWare.Button("Continue", "continue.gif", eWare.URL("PRCompany/PRCompanyRatingListing.asp") + "&E=PRCompany&T=Company&Capt=Rating", 'PRCompany', 'insert'));
    blkContainer.AddButton(eWare.Button("Change Notes", "edit.gif", eWare.URL("PRCompany/PRCompanyNotes.asp") + "&T=Company&Capt=Rating&notetype=FINANCIAL"));
    if (isUserInGroup(sSecurityGroups))
        blkContainer.AddButton(eWare.Button("New Statement", "new.gif", eWare.URL("PRFinancial/PRFinancialSummary.asp") +"&E=PRFinancial&T=Company&Capt=Rating", 'PRCompany', 'insert'));

    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage('Company'));

     Response.Write("\n<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    Response.Write("\n<script type=\"text/javascript\">");
    Response.Write("\n    function initBBSI()"); 
    Response.Write("\n    { ");
    
    if (sInsertString.length > 0) {
        Response.Write("\n    " + sInsertString);
    }

    Response.Write("\n    }");
    Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
    Response.Write("\n</script>");

%>
<!-- #include file="CompanyFooters.asp" -->
