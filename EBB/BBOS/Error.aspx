<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="Error.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Error" Title="Untitled Page" %>
<%@ Register Src="~/UserControls/ErrorDisplay.ascx" TagName="ErrorDisplay" TagPrefix="BBOS" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <BBOS:ErrorDisplay ID="error" runat="server" />
</asp:Content>
