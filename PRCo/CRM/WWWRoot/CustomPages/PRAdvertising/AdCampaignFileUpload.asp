<%@ CodePage=1252 Language="VBScript" %>
<% Option Explicit %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<!-- #include file="../upload.asp" -->
<%
    '/////////////////////////////////////////////////////////
    '//Filename: PRCompanyAdvertisingUpload.asp
    '//Author:           Tad M. Eness
    '//
    '//////////////////////////////////////////////////
    Public sFileNameField
    Public sUploadedFileName
    Public sBodyLoad
    Public sStatusCode

    doPage()
    
    Public Sub doPage()
        ' Create the FileUploader
        Dim sAction, sBBID
        Dim fso, Uploader, File
        Dim sUploadPath
        Dim sDestFilePath, sDestFileDir
        Dim sOldUploadFileName, sOldUploadFilePath
        
        Set fso = CreateObject("Scripting.FileSystemObject")

        ' This starts the upload process 
        Set Uploader = New FileUploader 
        Uploader.Upload()

        sUploadPath = Trim(CStr(Uploader.Form("hdnUploadBaseDir")))
        If (Len(sUploadPath) > 0) Then
            If (Right(sUploadPath, 1) <> "\") Then  ' in case it's in custom captions already
                sUploadPath = sUploadPath & "\"
            End If
        End If
        
        sOldUploadFileName = Trim(CStr(Uploader.Form("hdnOldUploadFileName")))
        sAction = Trim(CStr(Uploader.Form("hdnAction")))
        sBBID = Trim(CStr(Uploader.Form("hdnBBID")))

        sStatusCode = "0"       ' default to success
        If Uploader.Files.Count > 0 Then 
            ' there will only be one, but leaving the loop here.
            For Each File In Uploader.Files.Items
                If Len(sBBID) > 0 Then
                    sDestFileDir = sUploadPath & sBBID
                    On Error Resume Next
                    If Not fso.FolderExists(sDestFileDir) Then
                        fso.CreateFolder(sDestFileDir)
						If Err.number <> 0 Then
							Response.Write("52 Error: " & Err.Description & ", Folder: " & sDestFileDir)
							Response.End
						End If
                    End If
					On Error Goto 0
                    
                    ' The old file name will already have the relative path defined, just concat the base path to it.
                    sDestFilePath = sDestFileDir & "\" & File.FileName
                    sOldUploadFilePath = sUploadPath & sOldUploadFileName

                    If fso.FileExists(sDestFilePath) Then
                        ' fso.DeleteFile(sDestFilePath)
                        sStatusCode = "1"
                    Else
                        File.SaveToDisk sDestFileDir
                    End If
                    sUploadedFileName = Mid(sDestFilePath, Len(sUploadPath) + 1)
                End If
            Next 
        End If
        
        If (sAction = "PostBack") Then
            sBodyLoad = "Submit_Parent();"
        End If
        
    End Sub
 %>
<head>
    <title>PRCompanyAdvertisingUpload</title>
    <script type="text/javascript" language="javascript">
        function Form_Submit()
        {
            var CurrForm = document.forms("EntryForm");
            var ParentForm = window.parent.document.forms("EntryForm");

            // get the directory to store this in from the parent form.
            CurrForm.elements("hdnBBID").value = ParentForm.elements("pradc_companyid").value || -1;
            CurrForm.elements("hdnUploadBaseDir").value = ParentForm.elements("_uploadbasedir").value || "";
            CurrForm.elements("hdnOldUploadFileName").value = ParentForm.elements("pracf_filename").value || "";
            CurrForm.elements("hdnAction").value = "PostBack";
        }
        
        function Submit_Parent()
        {
            /*
                get the parent form
                submit the "EntryForm" on the parent.
            */
            var oParentForm = window.parent.document.forms("EntryForm");
            if (oParentForm.onsubmit) {
                oParentForm.onsubmit();
            }
            oParentForm.submit();
        }
    </script>
</head>
<body onload="<%= sBodyLoad %>">
    <form id="EntryForm" action="AdCampaignFileUpload.asp" onsubmit="Form_Submit();" method="post" enctype="multipart/form-data" >
        <input id="hdnStatus" name="hdnStatus" type="hidden" value="<%= sStatusCode %>"/>
        <input id="hdnAction" name="hdnAction" type="hidden" value="" />
        <input id="hdnBBID" name="hdnBBID" type="hidden" value="" />
        <input id="hdnUploadBaseDir" name="hdnUploadBaseDir" type="hidden" value="" />
        <input id="hdnUploadedFileName" name="hdnUploadedFileName" type="hidden" value="<%= sUploadedFileName %>" />
        <input id="hdnOldUploadFileName" name="hdnOldUploadFileName" type="hidden" value="" />
        <span><input id="_upload_filename" name="_upload_filename" type="FILE" style="width:100%" /></span>
        <!-- <span class=\"VIEWBOXCAPTION\"><input id="FILE1" name="_upload_filename" class="EDIT" type="FILE" style="width:100%" /></span> -->
        <!-- <input id="temp" type="submit" /> uncomment for testing in isolation -->
    </form>
</body>
</html>
