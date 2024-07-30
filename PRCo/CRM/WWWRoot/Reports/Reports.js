<%@ Language=JavaScript%>
<%
	// This is the standard include file for ASP based reports.
	// This file should be included on the first line of your Report file.
	// Do not alter, add or remove any code from this file!
	eWare = Server.CreateObject("eWare.eWare");
	Report = eWare.OpenReports(Request.QueryString,
                             Request.Form,
                             Request.ServerVariables("HTTP_USER_AGENT"),
                             Request.ServerVariables("HTTP_ACCEPT"));
%>

