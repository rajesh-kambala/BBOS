<!-- #include file="adovbs.inc" -->
<!-- #include file="Functions.asp" -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>PRCo EBB Development Project Website</title>
	<link rel=stylesheet type="text/css" href="prco.css">
	<style>
	.failure {font-weight:bold;color:red;}
	.success {font-weight:bold;color:green;}	
	</style>
</head>

<body>
  
<%
	Set oFSO = CreateObject("Scripting.FileSystemObject")
	szRoot = server.mappath("/EBBProjectSite/")

'function DoSomething()
	szFileName = szRoot + "\development.asp"
	set oFile = oFSO.GetFile(szFileName)
	szDateModified = oFile.DateLastModified

	if oFSO.FileExists(szRoot+"\CRM\EBB\WebSite\EBB\bin\EBB.dll") then
		szBuildNumber = oFSO.GetFileVersion(szRoot+"\CRM\EBB\WebSite\EBB\bin\EBB.dll")
	end if 
	
	set oLogFolder = oFSO.GetFolder(szRoot + "\CRM\BuildLog")
	For Each oFile in oLogFolder.Files
	    if Right(oFile.Name, 4) = ".txt" then
    		szLogFileName = oFile.Name
		end if
	Next

	'Determine Build Status
'	set oStatusFolder = oFSO.GetFolder(szRoot + "\PAIS\Build\Status")
'	For Each oFile in oStatusFolder.Files
'		if oFile.Name <> "Finished.txt" then
'		    szStatus = "Build In Progress: " + Left(oFile.Name, Len(oFile.Name)-4)
'		end if
'	Next
%>  

<table width=800><tr>
<td><img src="images/BBSSeal.gif" alt="" width="60" height="59" border="0" align=middle></td>
<td width=100%>
	<h1>EBB Development Project Website</h1>
	<table>
	<tr><td><strong>Site Last Updated:</strong></td><td><% =szDateModified %></td></tr>
	<tr><td><strong>Current Build:</strong></td><td><% =szBuildNumber %></td></tr>
	</table>
</td>
<td><img src="images/TravantTSLogo60.gif" alt="" width="60" height="54" border="0"></td>
</tr></table>

<% if szStatus <> "" then %>
<div style="width:800;font-size:12pt;color:red;font-weight:bold;" align="center">
<%= szStatus %>
</div>
<% end if %>

<div style="width:800;" align=center>
<hr>
<span style="font-size:12pt;">
<a href="http://defecttracker.travant.com" target="winDT">TSI Defect Tracker</a>
</span>
   
<p>
<div align=center>
<a href="#artifacts">Development Artifacts</a> | <a href="#status">Status Reports</a> | <a href="#prototypes">Unit Testing</a> | <a href="#stats">Code Stats</a> | <a href="#build">Build History</a>
</div>

 
</div>


<br>
<table width=800>
<tr><td valign=top width=50%>

	<fieldset style="height:275;"><legend><a name="artifacts">Development Artifacts</a></legend>
		<table>
<!--		
		<tr><td align=center valign=top><img src="images/fileicon-msword.gif"></td><td><a href="Deliverables/PAIS Application Settings.doc">PAIS Application Settings</a><br><%= szFileAttributes("Deliverables/PAIS Application Settings.doc") %></td></tr>
		<tr><td align=center valign=top><img src="images/fileicon-msexcel.gif"></td><td><a href="Reference Material/PAIS Security Matrix.xls">PAIS Security Matrix.xls</a><br><%= szFileAttributes("Reference Material/PAIS Security Matrix.xls") %></td></tr>
-->		
		<tr><td align=center valign=top><img src="images/fileicon-html.gif"></td><td><a href="CRM/doc/api/index.html" target=doc>PRCo Systems Framework API Documentation</a><br><%= szDateChanged("CRM/doc/api/index.html") %></td></tr>
		<tr><td align=center valign=top><img src="images/fileicon-html.gif"></td><td><a href="CRM/doc/database/CRM/index.html" target=dbdoc>CRM (PIKS Core) Database Documentation</a><br><%= szDateChanged("CRM/doc/database/CRM/index.html") %></td></tr>
		<tr><td align=center valign=top><img src="images/fileicon-html.gif"></td><td><a href="CRM/doc/database/BBSInterface/index.html" target=dbdoc>BBS Interface Database Documentation</a><br><%= szDateChanged("CRM/doc/database/BBSInterface/index.html") %></td></tr>		
		<tr><td></td></tr>
		</table>
	</fieldset>

</td><td valign=top width=50%>

	<fieldset style="height:275;"><legend>Latest Build Information</legend>
<%
	szFileName = szRoot + "\EBBBuildNumber.txt"
	set oFile = oFSO.GetFile(szFileName)
	szDateModified = oFile.DateLastModified
%>

		<div align=center><strong><% =szBuildNumber %></strong> created on <strong><% =szDateModified %></strong></div>
		<table>
		<tr><td align=center valign=top><img src="images/fileicon-html.gif"></td><td><a href="/WebSite/EBB/">EBB Web Application</a></td></tr>
		<tr><td align=center valign=top><img src="images/fileicon-html.gif"></td><td><a href="/WebSite/EBBWebService/">EBB Web Service</a></td></tr>
		<tr><td align=center valign=top><img src="images/fileicon-html.gif"></td><td><a href="/WebSite/">PRCo Marketing Web Site</a></td></tr>
		<tr><td align=center valign=top><img src="images/fileicon-html.gif"></td><td><a href="/CRM2/">CRM</a></td></tr>
		<tr><td align=center valign=top><img src="images/fileicon-html.gif"></td><td><a href="http://sql01/Reports/">PRCo Reports (Reporting Services)</a></td></tr>

<!--
		<tr><td colspan=2><hr></td></tr>
		<tr><td align=center valign=top><img src="images/fileicon-text.gif"></td><td><a href="PAIS/Build/Latest/Log/<% =szLogFileName %>">Log File</a></td></tr>
		<tr><td align=center valign=top><img src="images/fileicon-html.gif"></td><td><a href="PAIS/Build/Latest/NUnit/ReportSQLServer.html">PAIS Framework SQL Server Unit Test Report</a></td></tr>
		<tr><td align=center valign=top><img src="images/fileicon-html.gif"></td><td><a href="PAIS/Build/Latest/NUnit/ReportMSAccess.html">PAIS Framework MS Access Unit Test Report</a></td></tr>
		<tr><td align=center valign=top><img src="images/fileicon-html.gif"></td><td><a href="PAIS/Build/Latest/NUnit/ReportPAISSyncUTP.html">PAIS Sync Unit Test Report</a></td></tr>
		<tr><td align=center valign=top><img src="images/fileicon-html.gif"></td><td><a href="PAIS/Build/Latest/NUnit/ReportPAISReportingUTP.html">PAIS Reporting Unit Test Report</a></td></tr>
		<tr><td align=center valign=top><img src="images/fileicon-html.gif"></td><td><a href="PAIS/Build/Latest/NUnit/ReportPAISMonitorUTP.html">PAIS Monitor Unit Test Report</a></td></tr>		
-->		
		</table>
	</fieldset>

</td></tr>

<tr><td valign=top width=50%>
	<fieldset style="height:225;"><legend><a name="status">Status Reports</a></legend>
  
	<table>
<!--	
	<tr><td align=center valign=top><img src="images/fileicon-msexcel.gif"></td><td><a href="Project Management\PAIS Issues Log.xls">PAIS Issues Log.xls</a><br><%= szFileAttributes("Project Management\PAIS Issues Log.xls") %></td></tr>
-->
<%
	szFolderName = server.mappath("Project Management\Status Reports")
	set oFolder = oFSO.GetFolder(szFolderName)

	Set rstFiles = Server.CreateObject("ADODB.Recordset")
	rstFiles.Fields.Append "name", adVarChar, 255
	rstFiles.Fields.Append "date", adDate
	rstFiles.Open
	For Each oFile in oFolder.Files
		rstFiles.AddNew
		rstFiles.Fields("name").Value = oFile.Name
	Next
	rstFiles.Sort = "name DESC"

	if rstFiles.EOF = false then
		rstFiles.MoveFirst
	end if

	Do While Not rstFiles.EOF 
%>
	<tr><td align=center valign=top><img src="images/fileicon-msword.gif"></td><td><a href="Project Management\Status Reports\<% =rstFiles.Fields("name").Value %>"><% =rstFiles.Fields("name").Value %></a></td></tr>
<%
       rstFiles.MoveNext
	Loop
	set oFolder = nothing
%>
	</table>
	</fieldset>
</td><td valign=top width=50%>
	<fieldset style="height:225;"><legend>Unit Testing</legend>
	
<!--	
		<table>
		<tr><td align=center valign=top><img src="images/fileicon-binary.gif"></td><td><a href="PAISNUnit/SQLServer/PAISBusinessObjectsUTP.dll">PAIS Framework UTP</a><br><%= szFileAttributes("PAISNUnit/SQLServer/PAISBusinessObjectsUTP.dll") %></td></tr>
		<tr><td align=center valign=top></td><td>- <a href="javascript:confirmNUnit(true);">Execute via NUnitWeb (SQL Server)</a> (<a href="PAISNUnit/SQLServer/PAISBusinessObjectsUTP.dll.config">config file</a>)</td></tr>
		<tr><td align=center valign=top></td><td>- <a href="javascript:confirmNUnit(false);">Execute via NUnitWeb (MS Access)</a> (<a href="PAISNUnit/MSAccess/PAISBusinessObjectsUTP.dll.config">config file</a>) (<a href="PAISNUnit/MSAccess/PAISBusinessObjectsUTP.mdb">database</a>)</td></tr>
		</table>
		<br>&nbsp;
		<table>
		<tr><td align=center valign=top><img src="images/fileicon-binary.gif"></td><td><a href="PAISNUnit/Reporting/PAISReportingUTP.dll">PAIS Reporting UTP</a><br><%= szFileAttributes("PAISNUnit/Reporting/PAISReportingUTP.dll") %></td></tr>
		<tr><td align=center valign=top></td><td>- <a href="javascript:confirmReportingNUnit(true);">Execute via NUnitWeb (SQL Server)</a> (<a href="PAISNUnit/Reporting/PAISReportingUTP.dll.config">config file</a>)</td></tr>
		</table>
		<br>&nbsp;
		<div align=center><a href="http://www.nunit.org/download.html" target="NUnitOrg">Download NUnit Framework v2.2.1</a><br>(It's more fun to run the tests w/the NUnit GUI)</div>
		
-->		
	</fieldset>
</td></tr>

<tr><td colspan=2>
	<fieldset style="height:310;"><legend><a name="stats">Code Stats</a></legend>
	<iframe width=790 height=310 src="CRM/BuildLog/LineCount.html" scrolling=no></iframe>
	</fieldset>

</td><td>

</td></tr>
	
<tr><td colspan=2 valign=top width=100%>


	<fieldset style="height:150;"><legend><a name="build">Build History</a></legend>
	<table cellspacing=0 cellpadding=0 class="stdTable">
	<tr class="shaderow">
		<td class="colHeader" width="150">Date</th>
		<td class="colHeader" width="75">Version</th>
		<td class="colHeader" width="75">Status</th>
		<td class="colHeader" width="250">Log File</th>		
	</tr>
<%
	szFolderName = server.mappath("/EBBProjectSite/")
	set oBuildFolder = oFSO.GetFolder(szFolderName)

	szTableBuffer = ""

	Set rstFiles = Server.CreateObject("ADODB.Recordset")
	rstFiles.Fields.Append "name", adVarChar, 255
	rstFiles.Fields.Append "date", adDate
	rstFiles.Open
	For Each oFolder in oBuildFolder.SubFolders
		rstFiles.AddNew
		rstFiles.Fields("name").Value = oFolder.Name
		rstFiles.Fields("date").Value = oFolder.DateCreated
	Next
	rstFiles.Sort = "date DESC"

	rstFiles.MoveFirst

	szFolderName = szFolderName + "\"
	Do While Not rstFiles.EOF 

		set oFolder = oFSO.GetFolder(szFolderName + rstFiles.Fields("name").Value)
		if (Left(oFolder.Name, 6) = "CRM 3.") then
			szBuildNumber = Right(oFolder.Name, len(oFolder.Name)-4)

			szCreateDate =FormatDateTime(oFolder.DateCreated, 2) & " " + FormatDateTime(oFolder.DateCreated, 3)
			szStatus = "<span class=""success"">Success</span>"
			For Each oFile in oFolder.Files
			    if Right(oFile.Name, 12) = "BuildLog.txt" then
					if (InStr(oFile.Name, "Success") > 0) then
						szStatus = "<span class=""success"">Success</span>"
					else
						szStatus = "<span class=""failure"">Failed</span>"
					end if
					szLogFileName = oFile.Name
				end if
			Next

			szRowBuffer = ""

			szRowBuffer = szRowBuffer +	"<tr>"
			szRowBuffer = szRowBuffer + "<td class=data align=center>"+ szCreateDate + "</td>"
			szRowBuffer = szRowBuffer + "<td class=data align=center>"+ szBuildNumber + "</td>"
			szRowBuffer = szRowBuffer + "<td class=data align=center>"+ szStatus + "</td>"
			szRowBuffer = szRowBuffer + "<td class=data align=center><a href=""#"">"+ szLogFileName + "</a></td>"
			szRowBuffer = szRowBuffer + "</td>"
			szRowBuffer = szRowBuffer + "</tr>"

			szTableBuffer = szTableBuffer + szRowBuffer
		end if
		rstFiles.MoveNext
	Loop

	' Close our ADO Recordset object
	rstFiles.Close
	Set rstFiles = Nothing

%>
	<% =szTableBuffer %>
	</table>
	</fieldset>
</td></tr>
</table>


<div class="footer" style="width:800;">
<hr>
Copyright &copy 2004-2007 Travant Solutions, Inc.<br>
All Rights Reserved<br>
Unauthorized access is prohibited.<br>
</div>	
</body>
</html>


<% 'end function %>