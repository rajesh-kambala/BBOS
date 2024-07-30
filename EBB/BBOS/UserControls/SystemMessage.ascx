<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SystemMessage.ascx.cs" Inherits="PRCo.BBOS.UI.Web.UserControls.SystemMessage" %>

<div class="tw-h-full portlet-grid panel-primary" id="pnlPrimary" runat="server">
    <div class="home-info-blocks block-1">
        <div class="home-info-blocks-header">
            <span id="iconTES" runat="server" class="msicon notranslate filled">chat</span><% =Resources.Global.MyMessageCenter%>
        </div>
        <div class="home-info-blocks-content">
            <p>
                <asp:Literal ID="litMessage" runat="server" />
            </p>
        </div>
    </div>
</div>
