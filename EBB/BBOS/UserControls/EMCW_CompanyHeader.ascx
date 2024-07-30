<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="EMCW_CompanyHeader.ascx.cs" Inherits="PRCo.BBOS.UI.Web.EMCW_CompanyHeader" %>
<div class="row nomargin">
    <div class="col-md-12">
        <% =Resources.Global.BBNumber %><asp:Literal ID="litBBID" runat="server" />
        <br />
        <asp:HyperLink ID="hlCompanyName" runat="server" CssClass="explicitlink" />
        <br />
        <asp:Literal ID="litLocation" runat="server" />
    </div>
</div>