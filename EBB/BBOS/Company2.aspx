<%--TODO:JMT remove Company2.aspx before prod--%>
<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="Company2.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Company2" Title="Blue Book Services" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="Sidebar" Src="UserControls/Sidebar.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyHero" Src="UserControls/CompanyHero.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyBio" Src="UserControls/CompanyBio.ascx" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Import Namespace="PRCo.EBB.BusinessObjects" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="contentMain" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
    <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" Visible="false" />
</asp:Content>

<asp:Content ID="contentLeftSidebar" ContentPlaceHolderID="contentLeftSidebar" runat="server">
    <!-- Left nav bar  -->
    <bbos:Sidebar id="ucSidebar" runat="server" MenuExpand="1" MenuPage="1"/>

    <!-- Main  -->
    <main class="main-content tw-flex tw-flex-col tw-gap-y-4">
        <bbos:CompanyHero id="ucCompanyHero" runat="server" />
        <bbos:CompanyBio id="ucCompanyBio" runat="server" />
    </main>
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">
    <script language="javascript" type="text/javascript">
    </script>
</asp:Content>