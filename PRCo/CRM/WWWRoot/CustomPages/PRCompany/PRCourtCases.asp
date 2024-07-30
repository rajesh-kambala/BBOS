<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<%
    lstMain = eWare.GetBlock("PPRCourtCasesGrid");
    lstMain.prevURL = eWare.URL(f_value);
    blkContainer.AddBlock(lstMain);

    sContinueAction = eWare.Url("PRCompany/PRCompanyRatingListing.asp") + "&T=Company&Capt=Rating";
    blkContainer.AddButton(eWare.Button("Continue","continue.gif",sContinueAction));
    eWare.AddContent(blkContainer.Execute("prcc_CompanyID=" + comp_companyid));

    Response.Write(eWare.GetPage('Company'));

%>
<!-- #include file="CompanyFooters.asp" -->