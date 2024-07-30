<% 
function szFileAttributes (szFileName)
	
	On Error Resume Next

	Set oFSO = CreateObject("Scripting.FileSystemObject")
	szFileName = server.mappath("/EBBProjectSite/") + "\" + szFileName
	set oFile = oFSO.getFile(szFileName)

	szReturn= "<span class=""filetemplatesdata"">(Size: " + GetFileSize(oFile) + "&nbsp;&nbsp;&nbsp;"
	szReturn = szReturn + GetDateModified(oFile)
	szReturn = szReturn + ") </span>"

	szFileAttributes = szReturn
end function 

function szDateChanged (szFileName)
	
	'On Error Resume Next

	Set oFSO = CreateObject("Scripting.FileSystemObject")
	szFileName = server.mappath("/EBBProjectSite/") + "\" + szFileName
	
	set oFile = oFSO.getFile(szFileName)

	szReturn= "<span class=""filetemplatesdata"">("
	szReturn = szReturn + GetDateModified(oFile)
	szReturn = szReturn + ") </span>"

	szDateChanged = szReturn
end function 


function szFileSize (szFileName)
	
	On Error Resume Next

	Set oFSO = CreateObject("Scripting.FileSystemObject")
	szFileName = sserver.mappath("/EBBProjectSite/") + "\" + szFileName
	set oFile = oFSO.getFile(szFileName)

	szReturn= "<span class=""filetemplatesdata"">(Size: " + GetFileSize(oFile) + ") </span>"

	szFileSize = szReturn
end function 


function GetFileSize (oFile)

	iSize =  oFile.size
	if iSize > 1048576 then
		szSize = CStr(Round((iSize / 1048575), 2)) + " MB"
	elseif iSize > 1024 then
		szSize = CStr(Round((iSize / 1024),1)) + " KB"
	else
		szSize  =  CStr(iSize) + " bytes"
	end if

	GetFileSize = szSize
end function 


function GetDateModified (oFile)

	szReturn = ""
	dtDateModified = oFile.DateLastModified
	
	iDiff = DateDiff("d", dtDateModified , Now)
	if iDiff <= 5 then
		szReturn = szReturn + " <font color=red>"
	end if

	szReturn = szReturn + "Last Updated: " + CStr(dtDateModified)

	if DateDiff("d", Now, dtDateModified ) <= 5 then
		szReturn = szReturn +  " </font>"
	end if

	GetDateModified = szReturn
end function 

%>