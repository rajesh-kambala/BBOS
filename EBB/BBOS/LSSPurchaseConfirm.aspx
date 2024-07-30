<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="LSSPurchaseConfirm.aspx.cs" Inherits="PRCo.BBOS.UI.Web.LSSPurchaseConfirm" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Label ID="hidTriggerPage" Visible="false" runat="server" />

    <div class="row nomargin mar_bot">
        <div class="col-md-12">
            <%=Resources.Global.LSSPurchaseConfirmTopText1 %>
        </div>
    </div>

    <div class="row nomargin_lr" id="rowLocalSourceAccess" runat="server" >
        <div class="col-md-12">
            <b>Local Source Access:&nbsp;</b>Cost:&nbsp;<asp:Literal ID="litCost_Existing" runat="server" />
        </div>
    </div>

    <div class="row nomargin_lr" id="rowAdditionalLicenses" runat="server">
        <div class="col-md-12">
            <b>Additional Local Source Licenses</b><br />
            Quantity:&nbsp;<asp:Literal ID="litQuantity_New" runat="server" /><br />
            Cost:&nbsp;<asp:Literal ID="litCost_New" runat="server" />
        </div>
    </div>

    <div class="row nomargin_lr mar_bot" id="rowEmptyMsg" runat="server" visible="false">
        <div class="col-md-12">
            <asp:Label ForeColor="Red" runat="server"><%=Resources.Global.NoBillableChangesLSS %></asp:Label>
        </div>
    </div>

    <div class="row nomargin_lr">
        <div class="col-md-12">
            <asp:LinkButton ID="btnPurchase" runat="server" CssClass="btn gray_btn" OnClick="btnPurchaseOnClick">
			    <i class="fa fa-caret-right" aria-hidden="true"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnPurchase %>" />
            </asp:LinkButton>
            <asp:LinkButton ID="btnReviseSection" runat="server" CssClass="btn gray_btn" OnClick="btnReviseSection_Click">
			    <i class="fa fa-caret-right" aria-hidden="true"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnReviseSections %>" />
            </asp:LinkButton>
        </div>
    </div>
</asp:Content>
