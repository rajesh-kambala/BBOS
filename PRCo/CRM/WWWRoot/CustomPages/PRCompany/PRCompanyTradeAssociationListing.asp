<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<%
    lstMain = eWare.GetBlock("PRCompanyTradeAssociationGrid");
    lstMain.prevURL = eWare.URL(f_value);;
    blkContainer.AddBlock(lstMain);
    blkContainer.AddButton(eWare.Button("Continue","continue.gif",eWare.Url("PRCompany/PRCompanyProfile.asp") + "&T=Company&Capt=Profile"));    

    if (isUserInGroup("1,2,3,4,5,6,10"))
    {
        blkContainer.AddButton(eWare.Button("New","New.gif", eWare.URL("PRCompany/PRCompanyTradeAssociation.asp")));
    }

    
    eWare.AddContent(blkContainer.Execute("prcta_CompanyID=" + comp_companyid));
    Response.Write(eWare.GetPage('Company'));    
%>
<!-- #include file="CompanyFooters.asp" -->