<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FileUpload.aspx.cs" Inherits="PRCo.BBS.CRM.CustomPages.PRGeneral.FileUpload" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit"%> 

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script>
        function onClientUploadComplete(sender, args) {
            var filename = args.get_fileName();
            parent.fileUploadCallback(filename);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:ScriptManager  id ="ScriptManager1" runat="server" />
            <ajaxToolkit:AjaxFileUpload 
                ID="AjaxFileUpload1"
                OnUploadComplete="AjaxFileUpload1_UploadComplete" 
                OnClientUploadComplete="onClientUploadComplete"
                AutoStartUpload="true"
                Mode="Auto" 
                MaximumNumberOfFiles="100"
                runat="server"  />

            <style>
                .ajax__fileupload_footer {
                    display: none;
                }
                .ajax__fileupload_selectFileButton {
                    display: none;
                }
                .ajax__fileupload_topFileStatus {
                    display: none;
                }
                .ajax__fileupload_queueContainer {
                    display: none;
                }
                .ajax__fileupload {
                    border:none;
                }
                .ajax__fileupload_dropzone{
                    background-color:white;
                    background-image: url("https://crm.bluebookservices.local/CRM/img/PRCo/file-drop.jpg");
                    background-repeat: no-repeat;
                    
                }
            </style>
            <script>
                Sys.Extended.UI.Resources.AjaxFileUpload_DropFiles = "";
            </script>

        </div>
    </form>
</body>
</html>
