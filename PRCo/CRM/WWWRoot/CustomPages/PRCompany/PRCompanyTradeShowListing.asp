<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<%
    lstMain = eWare.GetBlock("PRCompanyTradeShowGrid");
    lstMain.prevURL = eWare.URL(f_value);;
    
    blkContainer.AddBlock(lstMain);
    blkContainer.AddButton(eWare.Button("Continue","continue.gif",eWare.Url("PRCompany/PRCompanyProfile.asp") + "&T=Company&Capt=Profile"));    
    
    eWare.AddContent(blkContainer.Execute("prcts_CompanyID=" + comp_companyid));
    Response.Write(eWare.GetPage('Company'));    
%>
<!-- #include file="CompanyFooters.asp" -->