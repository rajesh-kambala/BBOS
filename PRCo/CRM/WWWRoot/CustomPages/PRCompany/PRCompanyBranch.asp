<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<%
    lstMain = eWare.GetBlock("PRCompanyBranchGrid");
    lstMain.prevURL = eWare.URL(f_value);
    blkContainer.AddBlock(lstMain);

    if (iTrxStatus == TRX_STATUS_EDIT)
    {
        blkContainer.AddButton( eWare.Button("New Branch","New.gif", 
                                eWare.URL("PRCompany/PRCompanyBranchNew.asp")) );
    }
    if (!isEmpty(comp_companyid)) 
    {
        eWare.AddContent(blkContainer.Execute("comp_PRHQId=" + comp_companyid));
    }

    Response.Write(eWare.GetPage('Company'));

%>
<!-- #include file="CompanyFooters.asp" -->
