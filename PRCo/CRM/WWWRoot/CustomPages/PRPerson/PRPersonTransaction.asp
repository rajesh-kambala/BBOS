<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="PersonIdInclude.asp" -->

<%
    // Define this value for the RedirectTopContent.asp functionality; usually defined
    // in PersonHeaders.asp but we do not include it here
    var sTopContentUrl = "PersonTopContent.asp";

    blkSearch = eWare.GetBlock("PRCompanyTransactionSearchBox");
    blkSearch.Title = "Search";

    blkList = eWare.GetBlock("CompanyPRTransactionGrid");
    blkList.GetGridCol("prtx_CreatedDate").OrderByDesc = true;
    blkList.prevURL = sURL;
    blkList.ArgObj = blkSearch;
    
    blkContainer = eWare.GetBlock('container');
    blkContainer.AddBlock(blkSearch);
    blkContainer.AddBlock(blkList);

    blkContainer.DisplayButton(Button_Default) = true;
    blkContainer.ButtonTitle="Search";
    blkContainer.ButtonImage="Search.gif";
    blkContainer.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));


    qry = eWare.CreateQueryObj("SELECT Capt_US FROM Custom_Captions WHERE Capt_Family = 'SSRS' AND capt_code='URL'");
    qry.SelectSQL();
    
    sReportURL = "javascript:ViewReport('" + qry("Capt_US") + "/CRMArchive/PersonTransactionSummary&PersonID=" + pers_personid + "&rc:Parameters=false');";
    var btnArchiveReport = eWare.Button("Archived Transactions Report", "componentpreview.gif", sReportURL);
    blkContainer.AddButton(btnArchiveReport);

    eWare.AddContent(blkContainer.Execute("prtx_PersonId=" + pers_personid));

    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");    
    Response.Write(eWare.GetPage('Person'));

%>
<!-- #include file ="../RedirectTopContent.asp" -->





