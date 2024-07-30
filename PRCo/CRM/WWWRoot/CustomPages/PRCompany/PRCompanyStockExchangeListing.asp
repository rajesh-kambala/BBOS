<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<%
    var sGridName = "PRCompanyStockExchangeGrid";
    var sAddNewPage = "PRCompany/PRCompanyStockExchange.asp";
    var sEntityCompanyIdName = "prc4_CompanyId";
    var sNewCaption = "New";
    
    // override the default continue location
    sContinueAction = "PRCompany/PRCompanyProfile.asp";
    tabContext = "&T=Company&Capt=Profile";
    var sSecurityGroups = "1,2,3,4,5,6,10";

%>
<!-- #include file ="CompanyListingPageInclude.asp" -->
<!-- #include file="CompanyFooters.asp" -->
