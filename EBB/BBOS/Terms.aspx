<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="Terms.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Terms" EnableEventValidation="true" Title="Untitled Page" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Label ID="lblTermsType" Visible="false" runat="server" />
    <asp:Label ID="lblReferrer" Visible="false" runat="server" />

    <div class="row text-left">
        <div class="col-xs-12 displayText">
            <asp:Literal ID="litTerms" runat="server" />
        </div>
    </div>

    <div class="row mar_top_10">
        <div class="col-xs-12">
            <asp:LinkButton OnClick="btnAcceptOnClick" ID="btnAccept" CssClass="btn btnWidthStd gray_btn" runat="server">
	                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Accept %>" />
            </asp:LinkButton>

            <asp:LinkButton OnClick="btnDeclineOnClick" ID="btnDecline" CssClass="btn btnWidthStd gray_btn" runat="server">
	                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Decline %>" />
            </asp:LinkButton>

            <asp:LinkButton OnClick="btnDoneOnClick" ID="btnDone" CssClass="btn btnWidthStd gray_btn" runat="server">
	                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Done %>" />
            </asp:LinkButton>
        </div>
    </div>
</asp:Content>
