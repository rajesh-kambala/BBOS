<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="PersonHeaders.asp" -->
<%
    var sSecurityGroups = sDefaultPersonSecurity;
    var sGridName = "PRPersonBackgroundGrid";
    var sAddNewPage = "PRPerson/PRPersonBackground.asp";
    var sEntityPersonIdName = "prba_PersonId";
    var sNewCaption = "New Background";
    tabContext = "&T=Person&Capt=Background";
%>
<!-- #include file ="PersonListingPageInclude.asp" -->
