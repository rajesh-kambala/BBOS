<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<%
    recPRPACAComplaints = eWare.FindRecord("vPRPACAComplaints", "prpa_CompanyID=" + comp_companyid);

    lstMain = eWare.GetBlock("PPRPACAComplaintsGrid");
    lstMain.prevURL = eWare.URL(f_value);
    lstMain.ArgObj = recPRPACAComplaints;

    blkContainer.AddBlock(lstMain);

    sContinueAction = eWare.Url("PRCompany/PRCompanyRatingListing.asp") + "&T=Company&Capt=Rating";
    blkContainer.AddButton(eWare.Button("Continue","continue.gif",sContinueAction));

    eWare.AddContent(blkContainer.Execute());

    Response.Write(eWare.GetPage('Company'));
%>
<!-- #include file="CompanyFooters.asp" -->