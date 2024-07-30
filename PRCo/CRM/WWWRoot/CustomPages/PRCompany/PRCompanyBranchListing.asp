<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<%
    lstMain = eWare.GetBlock("PRCompanyBranchGrid");
    lstMain.prevURL = eWare.URL(f_value);
    blkContainer.AddBlock(lstMain);

    sContinueAction = eWare.Url("PRCompany/PRCompanySummary.asp");
    blkContainer.AddButton(eWare.Button("Continue","continue.gif",sContinueAction));

    if (iTrxStatus == TRX_STATUS_EDIT)
    {
        blkContainer.AddButton( eWare.Button("New Branch","New.gif", 
                                eWare.URL("PRCompany/PRCompanyNew.asp")+"&comp_prtype=B") );
    }
    if (!isEmpty(comp_companyid)) 
    {
        eWare.AddContent(blkContainer.Execute("comp_PRHQId=" + comp_companyid + " And comp_PRType='B'"));
    }

    Response.Write(eWare.GetPage('Company'));

%>
<!-- #include file="CompanyFooters.asp" -->
