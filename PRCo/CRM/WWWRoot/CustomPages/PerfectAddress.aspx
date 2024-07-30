<%@ Page Language="c#" 
    AutoEventWireup="true" Inherits="PRCo.BBS.CRM.PerfectAddress" Codebehind="PerfectAddress.aspx.cs"
 %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <link rel="stylesheet" href="/CRM/eware.css"/>
    <title>Address Verification</title>

    <script type="text/javascript" src="PerfectAddress.js"></script>
    <script type="text/javascript">
        function Mirror() {
            window.parent.document.forms.item(0).name;
        }
    </script>

    <style type="text/css">
    .selectRow{ cursor:pointer;}
    </style>

</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:HiddenField ID="hidFirstTime" Value="Y" runat="server" />
        <asp:Table runat="server" ID="tblResults" CssClass="Content" BorderWidth="1px" 
            style="vertical-align:top; border-color:#ffffff;" Height="20px" Width="100%" GridLines="Both"
            cellspacing="0" cellpadding="1" />
    </div>
    </form>

    <script type="text/javascript">
        AutoSelectFirstRow();
    </script>
</body>
</html>
