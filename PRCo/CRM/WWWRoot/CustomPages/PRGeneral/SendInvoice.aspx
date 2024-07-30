<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SendInvoice.aspx.cs" Inherits="PRCo.BBS.CRM.SendInvoice" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript">
        function closeSuccess() {
            alert("The invoice has been sucessfully sent.");
            self.close();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:label id="lblMsg" runat="server" Font-Bold="True" ForeColor="Red"></asp:label>
    </div>
    </form>
</body>
</html>
