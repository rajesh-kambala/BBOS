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
    var sSecurityGroups = "1,2,3,10";

    // This needs to be defined prior to the following include.
    // setting this variable to ARAgingBy makes only the date fields visible
    sScreenType = "TESTo";
%>
<!-- #include file ="CompanyTradeActivityFilterInclude.asp" --> 
<!-- #include file ="PRCompanyTESAnalysisInclude.asp" --> 

<%
    var sGridFilterWhereClause = "prtesr_ResponderCompanyId =" + comp_companyid;
    if (!isEmpty(sFormStartDate))
        sGridFilterWhereClause += " AND prtesr_CreatedDate >= " + sDBStartDate;
    if (!isEmpty(sFormEndDate))
        sGridFilterWhereClause += " AND prtesr_CreatedDate <= " + sDBEndDate;

    var user_userid = eWare.getContextInfo("User", "User_UserId");

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    var blkReportHeader = eWare.GetBlock('content');
    var sMsg = "<table width=\"100%\" class=\"InfoContent\"><tr><td>You are currently viewing TES Forms sent TO " + recCompany("comp_Name") + "</td></tr></table> ";
    blkReportHeader.contents = sMsg;
    blkContainer.AddBlock(blkReportHeader);

    
    if (eWare.Mode == View || eWare.Mode == Find)
    {
        Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
        Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");

        //blkFilter is created in PRCompanyTradeInclude.asp
        blkFilter.Width = "95%";
        blkContainer.AddBlock(blkFilter);    
        
        var blkAnalysis = eWare.GetBlock("content");
        blkAnalysis.contents = generateTESAnalsyisBlock(sScreenType, comp_companyid, sDBStartDate, sDBEndDate);
        blkContainer.AddBlock(blkAnalysis);

        blkListing = eWare.GetBlock("PRTESToGrid");
        blkListing.DisplayButton(Button_Default) = false;
        recListing = eWare.FindRecord("PRTESRequest", sGridFilterWhereClause);

        // this is overridden when the grid is drawn; in Accpac 5.7 we cannot control order.
        recListing.OrderBy = "prtesr_CreatedDate Desc";
        blkContainer.AddBlock(blkListing);
        
        sContinueUrl = eWare.URL("PRCompany/PRCompanyTradeActivityListing.asp") + "&T=Company&Capt=Trade+Activity";
        blkContainer.AddButton(eWare.Button("Continue", "continue.gif", sContinueUrl));
        
               
        eWare.AddContent(blkContainer.Execute(recListing));
        Response.Write(eWare.GetPage('Company'));
    }
    
%>
<!-- #include file="CompanyFooters.asp" -->
