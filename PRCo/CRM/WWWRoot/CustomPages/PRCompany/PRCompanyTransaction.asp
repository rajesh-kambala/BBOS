<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->

<%
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

    if (recCompany.comp_PRLocalSource !=  "Y") {
        var btnCSItems = eWare.Button("C/S Items","edit.gif", eWare.URL("PRCreditSheet/PRCreditSheetListing.asp") + "&T=Company&Capt=Transactions");
        blkContainer.AddButton(btnCSItems);
    }

    qry = eWare.CreateQueryObj("SELECT Capt_US FROM Custom_Captions WHERE Capt_Family = 'SSRS' AND capt_code='URL'");
    qry.SelectSQL();
    
    sReportURL = "javascript:ViewReport('" + qry("Capt_US") + "/CRMArchive/TransactionSummary&CompanyID=" + comp_companyid + "&rc:Parameters=false');";
    var btnArchiveReport = eWare.Button("Archived Transactions Report", "componentpreview.gif", sReportURL);
    blkContainer.AddButton(btnArchiveReport);

    if (comp_companyid != null && comp_companyid != '') {
        eWare.AddContent(blkContainer.Execute("prtx_CompanyId=" + comp_companyid));
    }

    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");    
    Response.Write(eWare.GetPage('Company'));
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
%>
<!-- #include file="CompanyFooters.asp" -->
