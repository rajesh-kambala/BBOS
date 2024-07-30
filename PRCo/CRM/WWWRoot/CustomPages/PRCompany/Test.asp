<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%
    var user_userid = eWare.getContextInfo("User", "User_UserId");

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

 var sGridFilterWhereClause = "prt2_SubjectCompanyId =" + comp_companyid;

        Response.Write("<LINK REL=\"stylesheet\" HREF=\"../../prco.css\">");
        Response.Write("<script language=javascript src=\"../PRCoGeneral.js\"></script>");
        Response.Write("<script language=javascript src=\"ViewReport.js\"></script>");
        
        recListing = eWare.FindRecord("vPRTES", sGridFilterWhereClause);
        blkListing = eWare.GetBlock("PRTESAboutGrid");
        blkListing.ArgObj = recListing;
        entry=blkListing.GetGridCol("prte_Date");
        entry.OrderByDesc = true;
        blkContainer.AddBlock(blkListing);        
        
        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage('Company'));
        
    
%>
<!-- #include file="CompanyFooters.asp" -->        