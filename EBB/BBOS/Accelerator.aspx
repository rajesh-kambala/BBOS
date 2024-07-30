<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Accelerator.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Accelerator" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Import Namespace="TSI.Utils" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>BBOS Accelerator</title>
    <% =UIUtils.GetCSSTag(PageBase.CSS_FILE)%>
</head>
<body>
    <form id="form1" runat="server">
        <div style="width: 300px;">
            <!-- start page title -->
            <table width="100%" border="0" style="text-align: center" cellpadding="0" cellspacing="0" id="tblPageHeader" runat="server">
                <tr>
                    <td style="width: 21px">
                        <img src="<% =UIUtils.GetImageURL("subnav-left.gif") %>" alt="" width="21px" height="35px" /></td>
                    <td style="white-space: nowrap; width: 100%" class="pageTitle"><%=Resources.Global.BBOSPreview %></td>
                </tr>
            </table>
            <br />
            <!-- end page title -->

            <asp:Literal ID="litMsg" runat="server" />
        </div>
    </form>
</body>
</html>
