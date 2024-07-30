<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CreditCardPayment.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CreditCardPayment" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register Src="~/UserControls/CreditCardInput.ascx" TagName="CreditCardInput" TagPrefix="BBOS" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="contentHead" ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        $('document').ready(function () {

                Stripe.setPublishableKey("<%= Utilities.GetConfigValue("Stripe_Publishable_Key")%>");

                $('#btnPurchase').on('click', function (e) {
                    bEnableValidation = true;
                    preStdValidation(document.forms[0]);
                    if (!validateForm(document.forms[0]))
                        return false;
                    $('#btnPurchase').attr('tsiDisable', 'true');

                    e.preventDefault();
                    e.stopPropagation();

                    Stripe.card.createToken({
                        number: $('#txtCreditCardNumber').val(),
                        cvc: $('#txtCVV').val(),
                        exp_month: $('#txtExpirationMonth').val(),
                        exp_year: $('#txtExpirationYear').val(),
                        address_line1: $('#contentMain_ucCCI_txtStreet1').val(),
                        address_line2: $('#contentMain_ucCCI_txtStreet2').val(),
                        address_city: $('#contentMain_ucCCI_txtCity').val(),
                        address_state: $('#contentMain_ucCCI_ddlState').val(),
                        address_zip: $('#contentMain_ucCCI_txtPostalCode').val(),
                        address_country: $('#contentMain_ucCCI_ddlCountry').val(),
                    }, stripeResponseHandler);

                    Clear();
                });


                function stripeResponseHandler(status, response) {
                    var $form = $('form');
                    if (response.error) {
                        // Show the errors on the form
                        alert(response.error.message);
                    } else {
                        // response contains id and card, which contains additional card details 
                        var token = response.id;
                        // Insert the token into the form so it gets submitted to the server
                        $('#hfStripeToken').val(token);
                        // and submit
                        $form.get(0).submit();
                    }
                }

                function Clear() {
                    $('#txtCreditCardNumber').val('');
                    $('#txtCVV').val('');
                    $('#txtExpirationMonth').val('');
                    $('#txtExpirationYear').val('');
                }
            });
    </script>

    <script src="https://js.stripe.com/v2/"></script>
    <style>
        .form-control {
            width: 95%;
            float: left;
        }
        sup {
            top: 5px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <script type="text/javascript">
        function preStdValidation(form) {
            if (contentMain_ucCCI_ddlCountry[contentMain_ucCCI_ddlCountry.selectedIndex].value == "1") {
                contentMain_ucCCI_txtPostalCode.setAttribute("tsiRequired", "true");
                contentMain_ucCCI_ddlState.setAttribute("tsiRequired", "true");
                if (contentMain_ucCCI_ddlCountry != null)
                    contentMain_ucCCI_ddlCountry.setAttribute("tsiRequired", "true");
            } else {
                contentMain_ucCCI_txtPostalCode.removeAttribute("tsiRequired");
                contentMain_ucCCI_ddlState.removeAttribute("tsiRequired");
                if (contentMain_ucCCI_ddlCountry != null)
                    contentMain_ucCCI_ddlCountry.removeAttribute("tsiRequired");
            }

            return true;
        }
    </script>

    <asp:Label ID="ReturnURL" Visible="false" runat="server" />

    <div class="row">
        <div class="col-md-10 offset-md-2">
            <% =PageBase.GetRequiredFieldMsg() %>
        </div>
    </div>
    <div class="row">
        <div class="col-md-2 clr_blu text-nowrap">
            <% =Resources.Global.Product %>:
        </div>
        <div class="col-md-10">
            <asp:Label ID="lblProduct" runat="server" />
        </div>
    </div>
    <div class="row">
        <div class="col-md-2 clr_blu text-nowrap">
            <% =Resources.Global.SubTotal %>:
        </div>
        <div class="col-md-10">
            <div class="NumericLabelData">
                <asp:Literal ID="lblSubTotal" runat="server" />
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-2 clr_blu text-nowrap">
            <% =Resources.Global.Shipping %>:
        </div>
        <div class="col-md-10">
            <div class="NumericLabelData">
                <asp:Literal ID="lblShipping" runat="server" />
            </div>
        </div>
    </div>

    <asp:UpdatePanel ID="upTotals" runat="server">
        <ContentTemplate>
            <div class="row">
                <div class="col-md-2 clr_blu text-nowrap">
                    <% =Resources.Global.SalesTax %>:
                </div>
                <div class="col-md-10">
                    <div class="NumericLabelData">
                        <asp:Literal ID="lblSalesTax" runat="server" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-2 clr_blu text-nowrap">
                    <% =Resources.Global.TotalAmount %>:
                </div>
                <div class="col-md-10">
                    <div class="NumericLabelDataTopBorder">
                        <asp:Literal ID="lblTotal" runat="server" />
                    </div>
                </div>
            </div>

            <div class="row mar_bot">
                <div class="col-md-10 offset-md-2">
                    <asp:LinkButton Text="<% $ Resources:Global, ReviseSelections %>" OnClick="btnReviseOnClick" ID="btnRevise" CssClass="SmallButton" runat="server" Visible="false" />
                    <asp:LinkButton Text="<% $ Resources:Global, Recalculate %>" OnClick="CalculateCharges" ID="btnRecalc" CssClass="SmallButton" runat="server" Visible="false" />
                    <asp:Label ID="lblTaxMsg" CssClass="annotation" runat="server" />
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <BBOS:CreditCardInput ID="ucCCI" runat="server" />

    <div class="row mar_top20">
        <div class="col-md-12">
            <% =Resources.Global.CreditCardPurchaseMsg%>
        </div>
    </div>

    <div class="row mar_top_5">
        <div class="col-md-12">
            <input type="submit" id="btnPurchase" name="btnPurchase" value="<%=Resources.Global.Purchase %>" class="btn gray_btn" />
            
            <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancelOnClick">
		        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text='<%$Resources:Global, btnCancel %>' />
            </asp:LinkButton>
        </div>
    </div>
    
    <div class="row mar_top_5">
        <div class="col-md-12">
            <span class="PromoMsg"><asp:Literal ID="litPromoMsg" runat="server" /></span>
        </div>
    </div>

    <input type="hidden" name="hfStripeToken" id="hfStripeToken" />
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        bEnableValidation = false;
    </script>
</asp:Content>


