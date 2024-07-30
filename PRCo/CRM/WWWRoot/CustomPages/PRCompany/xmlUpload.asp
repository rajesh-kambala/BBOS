<script language="vbscript" runat="SERVER">

   Response.Expires = 0

   ' define variables and COM objects
   dim ado_stream
   dim xml_dom
   dim xml_file1
   dim sFilePath
   dim arPath

   ' The current username and filename are passed
   ' in so the directory is created in the CRM library
   sFileName = Request.Querystring("filename")
   sFileDir = Request.Querystring("filedir")

   set ado_stream = Server.CreateObject("ADODB.Stream")
   set xml_dom = Server.CreateObject("MSXML2.DOMDocument")
   xml_dom.load(request)
   set xml_file1 = xml_dom.selectSingleNode("root/file1")

   ado_stream.Type = 1  ' 1=adTypeBinary
   ado_stream.open
   ado_stream.Write xml_file1.nodeTypedValue

   ' Create a filesystem object
   ' then loop through the directory
   ' passed from the email page which holds a unique
   ' date and the username.  this creates a folder on the server like
   ' crm - current user and a unique folder to add any
   ' email attachments to
   ' this string is also concatenated to the html form
   ' tag on the email page so that the email page, on postback,
   ' knows where to look when creating the communication
   ' and the directory
   Set objFS = Server.CreateObject("Scripting.FileSystemObject")
   sFileDir2 = split(sFileDir,"\")
   sPath = ""
   for i=0 to UBound(sFileDir2)
   	  sPath = sPath & sFileDir2(i) & "/"
   	  sDirectory = "d://crm57c/library/" & sPath
   		if objFS.FolderExists(sDirectory) then
   		else
   			sFilePath = objFS.CreateFolder(sDirectory)
   		end if
   next

   ' save the file in the path specified
   sFullFilePath = sDirectory & sFileName
   'Response.Write sFullFilePath
   ado_stream.SaveToFile sFullFilePath,2  ' 2=adSaveCreateOverWrite
   ado_stream.Close

   ' Send the filename back to the browser
   ' The filename will be written to the page
   ' in between the div tags
   ' see javascript at bottom of main email asp page
   Response.Write "<img src=../../img/Buttons/Attachmentsmall.gif align=middle> Attachments: "

   Set sFolderAttachments = objFS.GetFolder(sDirectory)
      For each file in sFolderAttachments.Files
   		Response.Write file.Name & "&nbsp;&nbsp;"
	  Next
   ' destroy COM object
   set ado_stream = Nothing
   set xml_dom = Nothing

</script>