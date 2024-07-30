<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2006-2015

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Blue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>

<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%
    // This needs to be defined prior to the following include.
    // setting this variable to ARAgingBy makes only the date fields visible
    sScreenType = "TESAbout";
%>
<!-- #include file ="CompanyTradeActivityFilterInclude.asp" --> 
<!-- #include file ="PRCompanyTESAnalysisInclude.asp" --> 

<%
    var sGridFilterWhereClause = "prtesr_SubjectCompanyId =" + comp_companyid;
    if (!isEmpty(sFormStartDate))
        sGridFilterWhereClause += " AND prtesr_CreatedDate >= " + sDBStartDate;
    if (!isEmpty(sFormEndDate))
        sGridFilterWhereClause += " AND prtesr_CreatedDate <= " + sDBEndDate;

    var user_userid = eWare.getContextInfo("User", "User_UserId");

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    var blkReportHeader = eWare.GetBlock('content');
    var sMsg = "<table width=\"100%\" class=\"InfoContent\"><tr><td>You are currently viewing TES Forms sent ABOUT " + recCompany("comp_Name") + "</td></tr></table> ";
    blkReportHeader.contents = sMsg;
    blkContainer.AddBlock(blkReportHeader);

    
    if (eWare.Mode == View || eWare.Mode == Find)
    {
        Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
        Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
        Response.Write("<script type=\"text/javascript\" src=\"ViewReport.js\"></script>");

        //blkFilter is created in PRCompanyTradeInclude.asp 
        blkFilter.Width = "95%";
        blkContainer.AddBlock(blkFilter);    
        
        
        sContinueUrl = eWare.URL("PRCompany/PRCompanyTradeActivityListing.asp") + "&T=Company&Capt=Trade+Activity";
        blkContainer.AddButton(eWare.Button("Continue", "continue.gif", sContinueUrl));
        
        sCustomRequestUrl = eWare.URL("PRTES/PRTESCustomRequest.asp") + "&T=Company&Capt=Trade+Activity";
        blkContainer.AddButton(eWare.Button("Custom TES Request", "new.gif", sCustomRequestUrl));
        
        
        var sSurveySQL = "SELECT dbo.ufn_GetReportURL('TESSummaryReport') As ReportURL";
        recQuery = eWare.CreateQueryObj(sSurveySQL);
        recQuery.SelectSql();
        var szReportURL = recQuery("ReportURL") + comp_companyid; 
        blkContainer.AddButton(eWare.Button("TES Request Summary Report","componentpreview.gif", "javascript:viewReport('" + szReportURL + "');"));


        var blkAnalysis = eWare.GetBlock("content");
        blkAnalysis.contents = generateTESAnalsyisBlock(sScreenType, comp_companyid, sDBStartDate, sDBEndDate);
        blkContainer.AddBlock(blkAnalysis);
        
        recListing = eWare.FindRecord("vPRTES", sGridFilterWhereClause);
        recListing.OrderBy = "prtesr_CreatedDate DESC";

        blkListing = eWare.GetBlock("PRTESAboutGrid");
        blkListing.GetGridCol("prtesr_CreatedDate").OrderByDesc = true;

        blkListing.ArgObj = recListing;
        blkContainer.AddBlock(blkListing);

        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage('Company'));
        
    }
%>
<!-- #include file="CompanyFooters.asp" -->
