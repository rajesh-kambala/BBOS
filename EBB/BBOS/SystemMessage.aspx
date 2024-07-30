<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="SystemMessage.aspx.cs" Inherits="PRCo.BBOS.UI.Web.SystemMessage" MaintainScrollPositionOnPostback="true" %>

<%@ Import Namespace="TSI.Utils" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row">
        <div class="col-md-12">
            <asp:Literal ID="litWelcomeMsg" runat="server" />
        </div>
    </div>
    <div class="row mar_top nomargin_lr">
        <div class="col-md-12">
            <asp:PlaceHolder ID="phMessageCener" runat="server" />
        </div>
    </div>
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        $(".messages").addClass("explicitlink");
    </script>
</asp:Content>