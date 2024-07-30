<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="Stripe_POC.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Stripe_POC" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">

        $('document').ready(function () {
            Stripe.setPublishableKey("<%= Utilities.GetConfigValue("Stripe_Publishable_Key")%>");

            $('#btnPay').on('click', function (e) {
                e.preventDefault();
                e.stopPropagation();

                Stripe.card.createToken({
                    number: $('#txtCardNumber').val(),
                    cvc: $('#txtCardSecurityCode').val(),
                    exp_month: $('#txtCardExpiryMonth').val(),
                    exp_year: $('#txtCardExpiryYear').val()
                }, stripeResponseHandler);
            });


            function stripeResponseHandler(status, response) {
                var $form = $('#form1');
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
        });
    </script>

    <script src="https://js.stripe.com/v2/"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
    

    <h1>Phase 1</h1>
    <div style="border-width:2px; border:solid; padding:20px;">
        <div>
            <asp:Label runat="server" Width="180">Card Number</asp:Label>
            <input type="text" id="txtCardNumber" placeholder="" name="txtCardNumber" value="4242424242424242" />
        </div>
        <div>
            <asp:Label runat="server" Width="180">Expiry Date</asp:Label>
            <input type="text" id="txtCardExpiryMonth" name="txtCardExpiryMonth" value="12" />
            /
	<input type="text" id="txtCardExpiryYear" name="txtCardExpiryYear" value="44" />
        </div>
        <div>
            <asp:Label runat="server" Width="180">Security Code</asp:Label>
            <input type="text" id="txtCardSecurityCode" name="txtCardSecurityCode" value="444" />
        </div>
        <br />
        <div>
            <input type="submit" id="btnPay" name="btnPay" value="Pay Now" />
        </div>
        <input type="hidden" name="hfStripeToken" id="hfStripeToken" />

        <br />
        <asp:Label ID="lblResult1" runat="server" />
        <br />
        <asp:Label ID="lblError1" runat="server" ForeColor="Red" />
    </div>

    <br />
    <h1>Phase 2</h1>
    <div style="border-width: 2px; border: solid; padding: 20px;">
        <asp:CheckBox ID="cbUseBBSStripe" runat="server" Checked="false" Text="Use BBS QA Stripe Key" />
        <br /><br />

        <table style=" table-layout: fixed; width: 100%; vertical-align:top">
            <tr>
                <td>
                    <asp:Button ID="btnCreateCustomer" runat="server" Text="Create Customer" OnClick="btnCreateCustomer_Click" Width="200"/>
                    <asp:Label ID="lblCustomerID" runat="server" />
                    <br /><br />
                </td>
                <td>            
                    <br />
                    <asp:Button ID="btnCreateInvoice" runat="server" Text="Create Invoice" OnClick="btnCreateInvoice_Click" Width="200" Enabled="false" />
                    <asp:Label ID="lblInvoiceID" runat="server" />
                    <br /><br />
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Button ID="btnCreateTaxRate" runat="server" Text="Create Tax Rate" OnClick="btnCreateTaxRate_Click" Width="200" Visible="false"/>
                    <asp:Label ID="lblTaxRate" runat="server" Visible="false" />

                    <br />
                </td>
            </tr>
            <tr>
                <td width="50%" style="vertical-align:top"><asp:Label ID="lblResult2Customer" runat="server" /></td>
                <td width="50%" style="vertical-align:top"><asp:Label ID="lblResult2Invoice" runat="server" /></td>
            </tr>
        </table>

        <asp:Label ID="lblError2" runat="server" ForeColor="Red" />
    </div>

<h1>Phase 3 - Stripe Component</h1>
    <div style="border-width: 2px; border: solid; padding: 20px;">
        <table style=" table-layout: fixed; width: 100%; vertical-align:top">
            <tr>
                <td>
                </td>
            </tr>
        </table>
    </div>

    <asp:Label ID="lblComponentResults" runat="server" />

    <div class="mar_top25">
        <asp:HyperLink runat="server" Text="Test Card Numbers" ForeColor="Blue" NavigateUrl="https://stripe.com/docs/testing" Target="_blank"  /><br />
        <asp:HyperLink runat="server" Text="Stripe API Reference" ForeColor="Blue" NavigateUrl="https://stripe.com/docs/api" Target="_blank" /><br />
    </div>
    
</asp:Content>
