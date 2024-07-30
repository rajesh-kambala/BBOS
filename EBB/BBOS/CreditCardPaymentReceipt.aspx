<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CreditCardPaymentReceipt.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CreditCardPaymentReceipt" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row">
        <div class="col-xs-12">
            <asp:Literal ID="litDupPurchase" runat="server" />
        </div>
    </div>

    <asp:Panel ID="pnlMain" runat="server">
        <div class="bold text-left">
            <asp:Label ID="lblMsg1" runat="server" />
        </div>

        <div class="text-left">
            <asp:Label ID="lblMsg2" runat="server" />
        </div>

        <asp:Label ID="hidRequestType" Visible="false" runat="server" />

        <div class="row mar_top">
            <div class="col-sm-2">
                <asp:Label CssClass="clr_blu" for="<%= lblPaymentID.ClientID%>" runat="server"><%= Resources.Global.BBOSOrderNumber %>:</asp:Label>
            </div>
            <div class="col-sm-10">
                <asp:Label ID="lblPaymentID" runat="server" />
            </div>
        </div>

        <div class="row">
            <div class="col-sm-2">
                <asp:Label CssClass="clr_blu" for="<%= lblCustomerName.ClientID%>" runat="server"><%= Resources.Global.CustomerName %>:</asp:Label>
            </div>
            <div class="col-sm-10">
                <asp:Label ID="lblCustomerName" runat="server" />
            </div>
        </div>

        <div class="row">
            <div class="col-sm-2">
                <asp:Label CssClass="clr_blu" for="<%= lblProduct.ClientID%>" runat="server"><%= Resources.Global.Product %>:</asp:Label>
            </div>
            <div class="col-sm-10">
                <asp:Label ID="lblProduct" runat="server" />
            </div>
        </div>

        <div class="row">
            <div class="col-sm-2">
                <asp:Label CssClass="clr_blu" for="<%= lblSubTotal.ClientID%>" runat="server"><%= Resources.Global.SubTotal %>:</asp:Label>
            </div>
            <div class="col-sm-10 NumericLabelData">
                <asp:Label ID="lblSubTotal" runat="server" />
            </div>
        </div>

        <div class="row">
            <div class="col-sm-2">
                <asp:Label CssClass="clr_blu" for="<%= lblSalesTax.ClientID%>" runat="server"><%= Resources.Global.SalesTax %>:</asp:Label>
            </div>
            <div class="col-sm-10 NumericLabelData">
                <asp:Label ID="lblSalesTax" runat="server" />
            </div>
        </div>

        <div class="row">
            <div class="col-sm-2">
                <asp:Label CssClass="clr_blu" for="<%= lblShipping.ClientID%>" runat="server"><%= Resources.Global.Shipping %>:</asp:Label>
            </div>
            <div class="col-sm-10 NumericLabelData">
                <asp:Label ID="lblShipping" runat="server" />
            </div>
        </div>

        <div class="row">
            <div class="col-sm-2">
                <asp:Label CssClass="clr_blu" for="<%= lblTotal.ClientID%>" runat="server"><%= Resources.Global.TotalAmount %>:</asp:Label>
            </div>
            <div class="col-sm-10 NumericLabelDataTopBorder">
                <asp:Label ID="lblTotal" runat="server" />
            </div>
        </div>

        <div class="row">
            <div class="col-sm-2">
                <asp:Label CssClass="clr_blu" for="<%= lblAuthorization.ClientID%>" runat="server"><%= Resources.Global.AuthorizationNumber %>:</asp:Label>
            </div>
            <div class="col-sm-10">
                <asp:Label ID="lblAuthorization" runat="server" />
            </div>
        </div>

        <div class="row">
            <div class="col-sm-2">
                <asp:Label CssClass="clr_blu" for="<%= lblCreditCardType.ClientID%>" runat="server"><%= Resources.Global.CreditCardType %>:</asp:Label>
            </div>
            <div class="col-sm-10">
                <asp:Label ID="lblCreditCardType" runat="server" />
            </div>
        </div>

        <div class="row">
            <div class="col-sm-2">
                <asp:Label CssClass="clr_blu" for="<%= lblCreditCardNumber.ClientID%>" runat="server"><%= Resources.Global.CreditCardNumber %>:</asp:Label>
            </div>
            <div class="col-sm-10">
                <asp:Label ID="lblCreditCardNumber" runat="server" />
            </div>
        </div>

        <div class="row">
            <div class="col-sm-2">
                <asp:Label CssClass="clr_blu" for="<%= lblStreet1.ClientID%>" runat="server"><%= Resources.Global.BillingAddress %>:</asp:Label>
            </div>
            <div class="col-sm-10">
                <asp:Label ID="lblStreet1" runat="server" />
            </div>
        </div>

        <div class="row">
            <div class="col-sm-10 offset-sm-2">
                <asp:Label ID="lblStreet2" runat="server" />
            </div>
        </div>

        <div class="row">
            <div class="col-sm-10 offset-sm-2 form-inline">
                <asp:Label ID="lblCity" runat="server" />,
                <asp:Label ID="lblState" runat="server" />
                <asp:Label ID="lblPostalCode" runat="server" />
            </div>
        </div>

        <div class="row">
            <div class="col-sm-10 offset-sm-2">
                <asp:Label ID="lblCountry" runat="server" />
            </div>
        </div>

        <div class="row">
            <div class="col-sm-10 offset-sm-2">
	            <asp:LinkButton ID="btnContinue" runat="server" CssClass="btn gray_btn" OnClick="btnContinueOnClick">
		            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnContinue %>" />
	            </asp:LinkButton>
            </div>
        </div>

        <asp:Panel ID="pnlMembershipTracking" runat="server" Visible="false">
            <!-- Google Code for Purchase Conversion Page -->
            <script type="text/javascript">
                /* <![CDATA[ */
                var google_conversion_id = 1051712544;
                var google_conversion_language = "en";
                var google_conversion_format = "3";
                var google_conversion_color = "ffffff";
                var google_conversion_label = "EKFvCL65gQIQoLi_9QM";
                var google_conversion_value = 0;
                if (655) {
                    google_conversion_value = 655;
                }
                /* ]]> */
            </script>
            <script type="text/javascript" src="https://www.googleadservices.com/pagead/conversion.js"></script>

            <noscript>
                <div style="display:inline;">
                    <img height="1" width="1" style="border-style:none;" alt="" src="https://www.googleadservices.com/pagead/conversion/1051712544/?value=655&amp;label=EKFvCL65gQIQoLi_9QM&amp;guid=ON&amp;script=0"/>
                </div>
            </noscript>
        </asp:Panel>

        <asp:Panel ID="pnlAlaCarteTracking" runat="server" Visible="false">
            <!-- Google Code for Purchase Ala Carte Conversion Page -->
            <script type="text/javascript">
                /* <![CDATA[ */
                var google_conversion_id = 1051712544;
                var google_conversion_language = "en";
                var google_conversion_format = "3";
                var google_conversion_color = "ffffff";
                var google_conversion_label = "ITerCLa6gQIQoLi_9QM";
                var google_conversion_value = 0;
                if (50.00) {
                    google_conversion_value = 50.00;
                }
                /* ]]> */
            </script>
            <script type="text/javascript" src="https://www.googleadservices.com/pagead/conversion.js"></script>
            <noscript>
                <div style="display:inline;">
                    <img height="1" width="1" style="border-style:none;" alt="" src="https://www.googleadservices.com/pagead/conversion/1051712544/?value=50.00&amp;label=ITerCLa6gQIQoLi_9QM&amp;guid=ON&amp;script=0"/>
                </div>
            </noscript>
        </asp:Panel>
    </asp:Panel>
</asp:Content>
