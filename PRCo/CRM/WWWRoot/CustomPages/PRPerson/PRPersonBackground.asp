<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="PersonHeaders.asp" -->

<%
    var sSecurityGroups = sDefaultPersonSecurity;
	var sAbbrEntityName = "PersonBackground";
	var sEntityPrefix = "prba";
    var sEntityPersonIdName = "prba_PersonId";
    var sNewEntryBlockTitle = "Person Background";
    tabContext = "&T=Person&Capt=Background";
%>

<!-- #include file ="PersonSummaryPageInclude.asp" -->