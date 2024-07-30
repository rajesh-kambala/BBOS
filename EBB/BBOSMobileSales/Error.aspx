<%@ Page Language="C#" MasterPageFile="~/BBSI.master" AutoEventWireup="true" CodeBehind="Error.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Error" Title="Untitled Page" %>
<%@ Register Src="~/UserControls/ErrorDisplay.ascx" TagName="ErrorDisplay" TagPrefix="BBOS" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Content2" runat="server">
    <BBOS:ErrorDisplay ID="error" runat="server" />
</asp:Content>