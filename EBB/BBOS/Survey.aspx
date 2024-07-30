<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Survey.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Survey1" %>

<%@ Register TagPrefix="sstchur" Namespace="sstchur.web.survey" Assembly="sstchur.web.survey" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <% =UIUtils.GetCSSTag(PageBase.CSS_FILE)%>
    <title><%=Resources.Global.Survey %></title>

    <script type="text/javascript">
        function closeNHARating() {
            //window.opener.enableCertificationQuiz();
            window.opener.location.reload();
            self.close();
        }
    </script>
</head>

<body>
    <form id="form1" runat="server">
        <asp:Panel ID="pnlSurvey" runat="server">
            <sstchur:WebSurvey ID="ws" runat="server" />
        </asp:Panel>

        <asp:Panel ID="pnlCompleted" runat="server" Visible="false">
            <p><%=Resources.Global.ThanksForCompletingQuiz %></p>

            <div style="text-align:center">
                <a href="javascript:self.close();" class="SmallButton"><%=Resources.Global.btnClose %></a>
            </div>
        </asp:Panel>
    </form>
</body>
</html>
