<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="EMCW_ARReports.aspx.cs" Inherits="PRCo.BBOS.UI.Web.EMCW_ARReports" %>

<%@ Register TagPrefix="bbos" TagName="EMCW_CompanyHeader" Src="~/UserControls/EMCW_CompanyHeader.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
    <bbos:EMCW_CompanyHeader ID="ucCompanyDetailsHeader" runat="server" />
    
    <asp:HiddenField ID="hidCompanyID" runat="server" />

    <asp:Panel ID="pnlNoEdit" CssClass="Title" Style="margin-left: 12px; margin-top: 10px; margin-bottom: 20px;" runat="server" Visible="false">
        <div class="row">
            <div class="col-md-12">
                <%= Resources.Global.NoEditRole%>
            </div>
        </div>
    </asp:Panel>

    <div class="text-left">
        <div class="row notice">
            <div class="col-md-12 text-center">
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
            </div>
        </div>

        <div class="row nomargin_lr mar_top">
            <div class="col-md-3">
                <div class="clr_blu"><% =Resources.Global.ARReportDate %>:</div>
            </div>
            <div class="col-md-3 label_top">
                <asp:TextBox ID="txtARDate" MaxLength="10" tsiDate="true" tsiDisplayName="<%$ Resources:Global, ARReportDate %>"
                    runat="server" tsiRequired="true" CssClass="form-control" />
                <cc1:CalendarExtender runat="server" ID="ceARDate" TargetControlID="txtARDate" />
            </div>
        </div>

        <div class="row nomargin">
            <div class="col-md-3">
                <div class="clr_blu"><% =Resources.Global.ARReportFile %>:</div>
            </div>
            <div class="col-md-9 label_top">
                <asp:FileUpload ID="fileARReport" runat="server" tsiRequired="true" tsiDisplayName="<%$Resources:Global, ARReportFile %>" />
            </div>
        </div>

        <div class="row mar_top nomargin_lr">
            <div class="col-md-12">
                <asp:LinkButton ID="btnSave" runat="server" CssClass="btn gray_btn" OnClick="btnSave_Click">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Save %>" />
                </asp:LinkButton>
                <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancel_Click">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
                </asp:LinkButton>
            </div>
        </div>
    </div>
</asp:Content>
