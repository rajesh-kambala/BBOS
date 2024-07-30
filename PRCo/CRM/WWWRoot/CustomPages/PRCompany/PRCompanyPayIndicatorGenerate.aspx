<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PRCompanyPayIndicatorGenerate.aspx.cs" Inherits="PRCo.BBS.CRM.PRCompanyPayIndicatorGenerate" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

</head>
<body>
    <script type="text/javascript">
        function displayMsg() {

            alert("<% =msg %>");
            location.href = "<% =url %>";
        }

    </script>

    <form id="form1" runat="server">
    <div>
    
        <asp:Literal ID="userMsg" runat="server" />

    </div>
    </form>
</body>
</html>
