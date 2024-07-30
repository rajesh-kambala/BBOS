<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CompanyHero.ascx.cs" Inherits="PRCo.BBOS.UI.Web.UserControls.CompanyHero" %>

<section class="company-hero">
    <img class="backdrop" id="img_companyHero" runat="server">
    <div class="company-logo" id="pnlImage" runat="server" >
        <asp:HyperLink id="hlLogo" Visible="false" Target="_blank" alt="Logo" runat="server" />
    </div>
    <button id="companyPrintButton" class="bbsButton bbsButton-secondary small" style="margin: 16px 16px;float: right;" onclick="window.print()">
        <span class="msicon notranslate">print</span>
        <span class="text-label"><%=Resources.Global.Print %></span>
    </button>
</section>