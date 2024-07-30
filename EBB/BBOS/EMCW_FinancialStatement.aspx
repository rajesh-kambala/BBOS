<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EMCW_FinancialStatement.aspx.cs"
    Inherits="PRCo.BBOS.UI.Web.EMCW_FinancialStatement" MasterPageFile="~/BBOS.Master" %>

<%@ Register TagPrefix="bbos" TagName="EMCW_CompanyHeader" Src="~/UserControls/EMCW_CompanyHeader.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
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
                <div class="clr_blu"><%= Resources.Global.LastStatementDate %>:</div>
            </div>
            <div class="col-md-3 label_top">
                <asp:Label ID="lblLastStatementDate" runat="server"/>
            </div>
        </div>

        <div class="row nomargin_lr">
            <div class="col-md-3">
                <div class="clr_blu"><%= Resources.Global.LastStatementType %>:</div>
            </div>
            <div class="col-md-3 label_top">
                <asp:Label ID="lblLastStatementType" runat="server"/>
            </div>
        </div>

        <div class="row nomargin_lr">
            <div class="col-md-3">
                <div class="clr_blu"><% =Resources.Global.StatementDate %>:</div>
            </div>
            <div class="col-md-2 label_top">
                <asp:TextBox ID="txtStatementDate" MaxLength="10" tsiDate="true" tsiDisplayName="<%$ Resources:Global, StatementDate %>"
                    runat="server" tsiRequired="true" CssClass="form-control" />
                <cc1:CalendarExtender runat="server" ID="ceStatementDate" TargetControlID="txtStatementDate" />
            </div>
        </div>

        <div class="row nomargin_lr">
            <div class="col-md-3">
                <div class="clr_blu"><% =Resources.Global.StatementType %>:</div>
            </div>
            <div class="col-md-3 label_top form-inline">
                    <asp:DropDownList ID="ddlStatementType" runat="server" CssClass="form-control"/>
                    &nbsp;&nbsp;
                    <span class="clr_blu" id="StatementMonths"><%= Resources.Global.Months %>:</span>
                    <asp:DropDownList ID="ddlMonths" runat="server" Enabled="false" CssClass="form-control"/>
            </div>
        </div>

        <div class="row nomargin_lr">
            <div class="col-md-3">
                <div class="clr_blu"><% =Resources.Global.StatementFile %>:</div>
            </div>
            <div class="col-md-3 label_top">
                <asp:FileUpload ID="fileStatement" runat="server" Width="500px" tsiRequired="true" tsiDisplayName="<%$Resources:Global, StatementFile %>" />
            </div>
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
</asp:Content>


