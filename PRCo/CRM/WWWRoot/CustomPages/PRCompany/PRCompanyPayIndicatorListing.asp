<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<%
    lstMain = eWare.GetBlock("PRPayIndicatorGrid");
    lstMain.prevURL = eWare.URL(f_value);
    entry=lstMain.GetGridCol("prcpi_CreatedDate");
    entry.OrderByDesc = true;
    
    blkContainer.AddBlock(lstMain);

    sContinueAction = "PRCompany/PRCompanyRatingListing.asp";
    blkContainer.AddButton(eWare.Button("Continue","continue.gif", eWare.Url(sContinueAction) + "&T=Company&Capt=Rating"));
    if (!isEmpty(comp_companyid)) 
    {
        eWare.AddContent(blkContainer.Execute("prcpi_CompanyId=" + comp_companyid));
    }

    Response.Write(eWare.GetPage('Company'));

%>
<!-- #include file="CompanyFooters.asp" -->
