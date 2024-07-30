<%@ CodePage=1252 Language="VBScript" %>
<% Option Explicit %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<!-- #include file="../upload.asp" -->
<%
    '/////////////////////////////////////////////////////////
    '//Filename: PRPublicationEditionUpload.asp
    '//Author:           Tad M. Eness
    '//
    '//  PRPublicationEditionUpload.asp is a wrapper for the VB Updload.asp file
    '//  to allow the JScript code to use the VBScript function.
    '//////////////////////////////////////////////////
    Public sEditionNameField
    Public sPublicationCodeField
    Public sFileNameField
    Public sUploadedFileName
    Public sBodyLoad
    Public sStatusCode
    
    Public Sub doPage()
        ' Create the FileUploader
        Dim sAction
        Dim fso, Uploader, File
        Dim sUploadPath, sDestPath, sDestFilePath
        Dim sPublicationName, sEditionName
        Dim sOldUploadFileName, sOldDestFilePath
        
        sStatusCode = "0"       ' default to success
        
        sEditionNameField = CStr(Request.QueryString("EditionNameField"))
        sPublicationCodeField = CStr(Request.QueryString("PublicationCodeField"))
        sFileNameField = CStr(Request.QueryString("FileNameField"))

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
        
        sPublicationName = Trim(CStr(Uploader.Form("hdnPublicationName")))
        sEditionName = Trim(CStr(Uploader.Form("hdnEditionName")))
        sOldUploadFileName = Trim(CStr(Uploader.Form("hdnOldUploadFileName")))
        sAction = Trim(CStr(Uploader.Form("hdnAction")))

        If Uploader.Files.Count > 0 Then 
            ' there will only be one, but leaving the loop here.
            For Each File In Uploader.Files.Items
                File.SaveToDisk sUploadPath

                If Len(sPublicationName) > 0 Then
                    sDestFilePath = sUploadPath & sPublicationName
                    If Not fso.FolderExists(sDestFilePath) Then
						On Error Resume Next
                        fso.CreateFolder(sDestFilePath)
                        If Err.number <> 0 Then
							Response.Write("<br />62 Error: " & Err.Description & ", Path: " & sDestFilePath)
							Response.End
                        End If
                        On Error GoTo 0
                    End If
                    If UCase(sPublicationName) = "BP" And Len(sEditionName) > 0 Then
                        sDestFilePath = sDestFilePath & "\" & sEditionName
                        If Not fso.FolderExists(sDestFilePath) Then
                            fso.CreateFolder(sDestFilePath)
                        End If
                    End If
                    
                    ' The old file name will already have the relative path defined, just concat the base path to it.
                    Dim sTempUpload
                    sTempUpload = sUploadPath & File.FileName
                    sDestFilePath = sDestFilePath & "\" & File.FileName
                    sOldDestFilePath = sUploadPath & sOldUploadFileName
                    If ((sTempUpload <> sOldDestFilePath) And fso.FileExists(sOldDestFilePath)) Then
                        fso.DeleteFile(sOldDestFilePath)
                    End If

                    If fso.FileExists(sDestFilePath) Then
                        fso.DeleteFile(sDestFilePath)
                    End If
                    
                    fso.MoveFile sUploadPath & File.FileName, sDestFilePath
                    
                    ' Update the uploaded filename
                    sUploadedFileName = Mid(sDestFilePath, Len(sUploadPath) + 1)
                    sStatusCode = "0"  ' return success
                    
                End If
            Next 
        End If
        
        If (sAction = "PostBack") Then
            sBodyLoad = "Submit_Parent();"
        End If
        
    End Sub

    doPage()
 %>
<head>
    <title>PRPublicationEditionUpload</title>
    <script type="text/javascript" language="javascript">
        function Form_Submit()
        {
            var CurrForm = document.forms("EntryForm");
            var ParentForm = window.parent.document.forms("EntryForm");

            // get the directory to store this in from the parent form.
            var sPath = String(ParentForm.elements("_uploadbasedir").value);
            CurrForm.elements("hdnUploadBaseDir").value = sPath;

            var sEditionName = String(ParentForm.elements("<%= sEditionNameField %>").value);
            if (sEditionName == "undefined")
                sEditionName = "";
            CurrForm.elements("hdnEditionName").value = sEditionName;

            var pc = ParentForm.elements("<%= sPublicationCodeField %>");
            var sPublicationName = pc.options[pc.selectedIndex].value;
            if (sPublicationName == "undefined" || sPublicationName.search(/^\-\-\s*none\s*\-\-$/i) >= 0)
                sPublicationName = "None";
            CurrForm.elements("hdnPublicationName").value = sPublicationName;

            var sOldCoverArtFileName = String(ParentForm.elements("<%= sFileNameField %>").value);
            if (sOldCoverArtFileName == "undefined")
                sOldCoverArtFileName = "";
            CurrForm.elements("hdnOldUploadFileName").value = sOldCoverArtFileName;
            
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
    <form id="EntryForm" action="PRPublicationUpload.asp" onsubmit="Form_Submit();" method="post" enctype="multipart/form-data" >
        <input id="hdnAction" name="hdnAction" type="hidden" />
        <input id="hdnStatus" name="hdnStatus" type="hidden" value="<%= sStatusCode %>"/>
        <input id="hdnUploadBaseDir" name="hdnUploadBaseDir" type="hidden" />
        <input id="hdnEditionName" name="hdnEditionName" type="hidden" />
        <input id="hdnPublicationName" name="hdnPublicationName" type="hidden" />
        <input id="hdnUploadedFileName" name="hdnUploadedFileName" type ="hidden" value="<%= sUploadedFileName %>"/>
        <input id="hdnOldUploadFileName" name="hdnOldUploadFileName" type="hidden" />
        <input id='_upload_filename' name='_upload_filename' class='EDIT' type='FILE' style='width:100%' />
    </form>
</body>
</html>
