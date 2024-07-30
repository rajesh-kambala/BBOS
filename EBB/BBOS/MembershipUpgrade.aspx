<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="MembershipUpgrade.aspx.cs" Inherits="PRCo.BBOS.UI.Web.MembershipUpgrade" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="text-left">
        <div class="row nomargin_lr mar_bot">
            <div class="col-md-12">
                <% = Resources.Global.ProratedInvoiceMsg %>
            </div>
        </div>

        <div class="row nomargin">
            <div class="col-md-2">
                <asp:Label ID="lblCustomHeaderText" CssClass="clr_blu" for="<%= lblProduct.ClientID%>" runat="server"><%= Resources.Global.Product %>:</asp:Label>
            </div>
            <div class="col-md-10">
                <asp:Label ID="lblProduct" runat="server" />
            </div>
        </div>

        <div class="row nomargin">
            <div class="col-md-2">
                <asp:Label ID="Label1" CssClass="clr_blu" for="<%= lblSubTotal.ClientID%>" runat="server"><%= Resources.Global.SubTotal %>:</asp:Label>
            </div>
            <div class="col-md-10">
                <div class="NumericLabelData">
                    <asp:Label ID="lblSubTotal" runat="server" />
                </div>
            </div>
        </div>

        <div class="row nomargin">
            <div class="col-md-2">
                <asp:Label ID="Label2" CssClass="clr_blu" for="<%= lblShipping.ClientID%>" runat="server"><%= Resources.Global.Shipping %>:</asp:Label>
            </div>
            <div class="col-md-10">
                <div class="NumericLabelData">
                    <asp:Label ID="lblShipping" runat="server" />
                </div>
            </div>
        </div>

        <div class="row nomargin">
            <div class="col-md-2">
                <asp:Label ID="Label3" CssClass="clr_blu" for="<%= lblSalesTax.ClientID%>" runat="server"><%= Resources.Global.SalesTax %>:</asp:Label>
            </div>
            <div class="col-md-2">
                <div class="NumericLabelData">
                    <div class="NumericLabelData">
                        <asp:Label ID="lblSalesTax" runat="server" />
                    </div>
                </div>
            </div>
            <div class="col-md-8">
                <asp:Label ID="lblTaxMsg" CssClass="annotation" runat="server" />
            </div>
        </div>

        <div class="row nomargin">
            <div class="col-md-2">
                <asp:Label ID="Label4" CssClass="clr_blu" for="<%= lblShipping.ClientID%>" runat="server"><%= Resources.Global.TotalAmount %>:</asp:Label>
            </div>
            <div class="col-md-10">
                <div class="NumericLabelDataTopBorder">
                    <asp:Label ID="lblTotal" runat="server" />
                </div>
            </div>
        </div>
    </div>

    <div class="row nomargin_lr mar_top">
        <div class="col-md-12">
            <asp:LinkButton ID="btnPurchase" runat="server" CssClass="btn gray_btn" OnClick="btnPurchaseOnClick">
			    <i class="fa fa-caret-right" aria-hidden="true"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnPurchase %>" />
            </asp:LinkButton>
            <asp:LinkButton ID="btnRevise" runat="server" CssClass="btn gray_btn" OnClick="btnReviseOnClick">
			    <i class="fa fa-caret-right" aria-hidden="true"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ReviseSelections %>" />
            </asp:LinkButton>
        </div>
    </div>
</asp:Content>
