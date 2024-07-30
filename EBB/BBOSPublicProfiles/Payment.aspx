<%@ Page Title="" Language="C#" MasterPageFile="~/Produce.Master" EnableEventValidation="false" AutoEventWireup="true" CodeBehind="Payment.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PublicProfiles.Payment" %>
<%@ MasterType VirtualPath="~/Produce.Master" %>
<%@ Import namespace="TSI.Utils" %>
<%@ Register TagPrefix="uc" TagName="MembershipHeader" Src="~/Controls/MembershipHeader.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="BBOSPublicProfilesHead" runat="server">
    <meta name="robots" content="noindex, nofollow">

    <style type="text/css">
        .input td {
            padding: 2px;
        }

        .label {
            font-weight: bold;
            white-space: nowrap;
        }

        .validationError {
            color: Red;
            text-align: left;
        }

            .validationError ul {
                list-style-type: disc;
                margin-left: 15px;
            }

                .validationError ul li {
                    color: Red;
                    margin-bottom: 0px;
                    padding: 0px;
                }

        .required {
            color: Red;
        }

        .bulletList {
            list-style-type: disc;
            margin-left: 25px;
            margin-top: 0px;
            font: 13px/1.4em "helvetica_neuelightcond", "Helvetica", Arial, serif;
        }

        .bulletListItem {
            margin-top: 5px;
        }

        .bulletListItem2 {
            margin-top: 0px;
            margin-bottom: 0px !important;
        }

        .NumericLabelDataTopBorder {
            border-top: black thin solid;
            width: 70px;
            text-align: right;
        }

        .NumericLabelData {
            width: 70px;
            text-align: right;
        }

        .annotation {
            font-size: 9px
        }

        .Popup {
            background: #fff;
            padding: 10px;
            border: 10px solid #ddd;
            /*-- border: 10px solid rgb(16, 37, 162);--*/
            float: left;
            font-size: 10pt;
            position: fixed;
            top: 50%;
            left: 50%;
            z-index: 99999;
            /*--CSS3 Box Shadows--*/
            -webkit-box-shadow: 0px 0px 20px #000;
            -moz-box-shadow: 0px 0px 20px #000;
            box-shadow: 0px 0px 20px #000;
            /*--CSS3 Rounded Corners--*/
            -webkit-border-radius: 10px;
            -moz-border-radius: 10px;
            border-radius: 10px;
        }

        .PopupLink {
            FONT-SIZE: 11px;
            color: Blue;
            text-decoration: underline;
            cursor: pointer;
        }

        .registertitle {
            width: 135px;
        }

        .registerinput {
            width: 200px;
        }

        .cbLabel input {
            vertical-align: middle;
            margin-right: 5px;
        }
    </style>

    <script type="text/javascript">

        function refreshPanel() {
            <%--__doPostBack("<%= upTotals.UniqueID %>", "");--%>
            document.getElementById('<%= btnRecalc.ClientID %>').click()
        }

        function processAddress() {
            if (($("#<% =txtCity.ClientID %>").val() != "") &&
                ($("#<% =ddlState.ClientID %>").val() != "") &&
                ($("#<% =txtPostalCode.ClientID %>").val() != "")) {
                refreshPanel();
            }
        }

        function validateCounty() {
            var selected = $(':radio:checked[name=rbCounty]');
            if (!selected.length) {
                alert("Please select a country.");
                return false;
            }
        }

        function setCounty(selectedCounty) {
            $('#<% =txtCounty.ClientID %>').val(selectedCounty);
        }

        function agree(cbAgree) {
            document.getElementById("btnPurchase").disabled = !(cbAgree.checked);
        }

        function validateTerms() {
            if (document.getElementById("cbAgreement")) {
                if (!document.getElementById("cbAgreement").checked) {
                    alert("<%=Resources.Global.ToPurchaseMustAgreeToTerms%>");
                    return false;
                }
            }

            return ready();
        }

        function selectFirstBR() {
            $("input[name=rbProductID]:first").attr('checked', true);
        }

        $(document).ready(function () {
            setResources();
            var selectedValue = $("#<% =productID.ClientID %>").val();

            if (selectedValue != "") {
                $('input[name="rbProductID"][value="' + selectedValue + '"]').prop('checked', true);
            } else {
                $("input[name=rbProductID]:first").attr('checked', true);
            }
        });

        function OnPageInit() {
            setResources();
        }

        function setResources() {
            var btntxt ='<%= lblPurchase.Text %>';
            $("#btnPurchase").prop('value', btntxt);
        }

        if (!inIframe()) {
            var expiredate = new Date();
            expiredate.setDate(expiredate.getDate() + 1);
            //document.cookie = "CompanyID=" + vars['CompanyID'] + ";expires=" + expiredate.toUTCString();

            if (document.location.hostname != "localhost") {
                window.location.href = "<% =GetMarketingSiteURL() %>/payment/";
            }
        }

        function produceDetailsChanged() {
            if (document.getElementById("<% =ddlHowLearned.ClientID %>").value == "Other") {
                document.getElementById("pHowLearnedOther").style.display = "";
            } else {
                document.getElementById("pHowLearnedOther").style.display = "none";
            }
        }

        function redirectToReceiptPage(bIsSpanish) {
            if (bIsSpanish)
                window.top.location.href = "/recibo-de-pago/";
            else
                window.top.location.href = "/payment-receipt/";
        }

        function ready() {
            var rcres = grecaptcha.getResponse();
            if (rcres.length)
                return true;

            alert("Please verify the reCAPTCHA challenge before clicking Submit.");
            return false;
        }

        function setPurchaseButtonState() {
            var bRecaptchaChecked = false;
            var bAgreeTermsChecked = false;

            var rcres = grecaptcha.getResponse();
            if (rcres.length)
                bRecaptchaChecked = true;

            if (document.getElementById("cbAgreement")) {
                if (document.getElementById("cbAgreement").checked) {
                    bAgreeTermsChecked = true;
                }
            }

            if (bRecaptchaChecked && bAgreeTermsChecked) {
                $('#BBOSPublicProfilesMain_btnPurchase').addClass('button');
                $('#BBOSPublicProfilesMain_btnPurchase').removeClass('aspNetDisabled');
            }
            else {
                $('#BBOSPublicProfilesMain_btnPurchase').removeClass('button');
                $('#BBOSPublicProfilesMain_btnPurchase').addClass('aspNetDisabled');
            }
        }

        jQuery(window).bind("load", function () {
            resizeIFrame();
        });

        jQuery(window).bind('resize', function () {
            resizeIFrame();
        });
    </script>

    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
    <script type="text/javascript" src="javascript/BootStrap.min.js" ></script>

    <script type="text/javascript">

        $('document').ready(function () {
            Stripe.setPublishableKey("<%= Utilities.GetConfigValue("Stripe_Publishable_Key")%>");

            $('#btnPurchase').on('click', function (e) {
                if (!preStdValidation(document.forms[0]))
                    return false;

                e.preventDefault();
                e.stopPropagation();

                stripePush();

                if (validateTerms()) {

                    Stripe.card.createToken({
                        number: $('#txtCreditCardNumber').val(),
                        cvc: $('#txtCVV').val(),
                        exp_month: $('#txtExpirationMonth').val(),
                        exp_year: $('#txtExpirationYear').val(),
                        name: $('#BBOSPublicProfilesMain_txtNameOnCard').val(),
                        address_line1: $('#BBOSPublicProfilesMain_txtStreet1').val(),
                        address_line2: $('#BBOSPublicProfilesMain_txtStreet2').val(),
                        address_city: $('#BBOSPublicProfilesMain_txtCity').val(),
                        address_state: $('#BBOSPublicProfilesMain_ddlState').val(),
                        address_zip: $('#BBOSPublicProfilesMain_txtPostalCode').val(),
                        address_country: $('#BBOSPublicProfilesMain_ddlCountry').val(),
                    }, stripeResponseHandler);


                }
            });


            function stripeResponseHandler(status, response) {
                var $form = $('#form1');
                if (response.error) {
                    // Show the errors on the form
                    stripePop();
                    alert(response.error.message);
                } else {
                    stripeClear();
                    // response contains id and card, which contains additional card details 
                    var token = response.id;
                    // Insert the token into the form so it gets submitted to the server
                    $('#hfStripeToken').val(token);
                    // and submit
                    $form.get(0).submit();
                }
            }

            function stripeClear() {
                $('#txtCreditCardNumber').val('');
                $('#hidCreditCardNumber').val('');
                $('#txtCVV').val('');
                $('#hidCVV').val('');
                $('#txtExpirationMonth').val('');
                $('#hidExpirationMonth').val('');
                $('#txtExpirationYear').val('');
                $('#hidExpirationYear').val('');
            }

            function stripePush() {
                $('#hidCreditCardNumber').val($('#txtCreditCardNumber').val());
                $('#hidCVV').val($('#txtCVV').val());
                $('#hidExpirationMonth').val($('#txtExpirationMonth').val());
                $('#hidExpirationYear').val($('#txtExpirationYear').val());
            }

            function stripePop() {
                $('#txtCreditCardNumber').val($('#hidCreditCardNumber').val());
                $('#txtCVV').val($('#hidCVV').val());
                $('#txtExpirationMonth').val($('#hidExpirationMonth').val());
                $('#txtExpirationYear').val($('#hidExpirationYear').val());
            }

        });
    </script>

    <script type="text/javascript">
        // Determines if the value is a
        // valid Internet e-mail address.
        const validateEmail = (email) => {
            return String(email)
                .toLowerCase()
                .match(
                    /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|.(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
                );
        };

        function preStdValidation(form) {
            var szMsg = "";

            var requiredMissing = false;
            if (!checkRequiredFields())
                szMsg += "One or more required fields are missing.<br>";

            if ($('#<% =BREmailAddress.ClientID %>').length) {
                if (!validateEmail($('#<% =BREmailAddress.ClientID %>').val())) {
                    szMsg += 'The specified email addresses is invalid.<br>';
                }

                if ($('#<% =BREmailAddress.ClientID %>').val() != $('#<% =BREmailAddressConfirm.ClientID %>').val()) {
                    szMsg += 'The specified email addresses do not match.<br>';
                }
            }

            if ($('#<% =txtSubmitterEmail.ClientID %>').length) {
                if (!validateEmail($('#<% =txtSubmitterEmail.ClientID %>').val())) {
                    szMsg += 'The specified email addresses is invalid.<br>';
                }
            }

            $("#errMsg2").html(szMsg);

            if (szMsg.length > 0) {
                return false;
            }

            return true;
        }

        function checkRequiredFields() {
            if (checkFieldMissing($('#<% =txtFirstName.ClientID %>'))) return false;
            if (checkFieldMissing($('#<% =txtLastName.ClientID %>'))) return false;
            if (checkFieldMissing($('#<% =txtSubmitterPhone.ClientID %>'))) return false;
            if (checkFieldMissing($('#<% =txtSubmitterEmail.ClientID %>'))) return false;
            if (checkFieldMissing($('#<% =txtCompanyName.ClientID %>'))) return false;
            if (checkFieldMissing($('#<% =ddlTypeofBusiness.ClientID %>'))) return false;
            if (checkFieldMissing($('#<% =txtNameOnCard.ClientID %>'))) return false;
            if (checkFieldMissing($('#<% =txtStreet1.ClientID %>'))) return false;
            if (checkFieldMissing($('#<% =txtCity.ClientID %>'))) return false;
            if (checkFieldMissing($('#<% =ddlState.ClientID %>'))) return false;
            if (checkFieldMissing($('#<% =ddlCountry.ClientID %>'))) return false;
            if (checkFieldMissing($('#<% =txtPostalCode.ClientID %>'))) return false;

            if (checkFieldMissing($('#<% =txtStreet1_Mailing.ClientID %>'))) return false;
            if (checkFieldMissing($('#<% =txtCity_Mailing.ClientID %>'))) return false;
            if (checkFieldMissing($('#<% =ddlState_Mailing.ClientID %>'))) return false;
            if (checkFieldMissing($('#<% =ddlCountry_Mailing.ClientID %>'))) return false;
            if (checkFieldMissing($('#<% =txtPostalCode_Mailing.ClientID %>'))) return false;

            if (checkFieldMissing($('#<% =ddlHowLearned.ClientID %>'))) return false;
            if ($('#<% =ddlHowLearned.ClientID %>').val() == "Other") {
                if (checkFieldMissing($('#<% =txtProduceHowLearnedOther.ClientID %>'))) return false;
            }

            if (checkFieldMissing($('#txtCreditCardNumber'))) return false;
            if (checkFieldMissing($('#txtCVV'))) return false;
            if (checkFieldMissing($('#txtExpirationMonth'))) return false;
            if (checkFieldMissing($('#txtExpirationYear'))) return false;

            return true;
        }

        function checkFieldMissing(ctrl) {
            if (ctrl.length && (ctrl.val().length == 0 || ctrl.val()=="0"))
                return true
            else
                return false;
        }
    </script>

    <script src="https://js.stripe.com/v2/"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="BBOSPublicProfilesMain" runat="server">
    <asp:HiddenField ID="productID" runat="server" />

    <div style="margin-left: auto; margin-right: auto">
        <div class="row">
            <h1><%=Resources.Global.PaymentAndBlueBookListing %></h1>
        </div>

        <div class="row">
            <div id="errMsg2" class="validationError"></div>
        </div>

        <div class="row">
            <div class="col-md-12">
                <uc:MembershipHeader ID="membershipHeader" CurrentStep="4" HideMembershipSummary="true" Visible="false" runat="server" />
            </div>

            <div class="col-md-12">
                <div style="width: 300px; margin-left: auto; margin-right: auto; margin: 10px;">
                    <asp:Label CssClass="validationError" ID="errMsg" runat="server" />
                    <asp:ValidationSummary CssClass="validationError" ValidationGroup="Required" HeaderText="<%$ Resources:Global, OneOrMoreRequiredFieldsMissing %>" DisplayMode="BulletList" runat="server" />
                </div>
            </div>
        </div>

        <asp:UpdatePanel ID="upTotals" UpdateMode="Conditional" runat="server">
            <ContentTemplate>
                <div class="row">
                    <div class="col-md-7 col-sm-12 vtop" id="divBR" runat="server">
                        <strong><%=Resources.Global.YouHaveSelectedToReceiveBRFor%>&nbsp;<asp:Literal ID="BRCompany" runat="server" /></strong><br />
                        <asp:Literal ID="BRPrice" runat="server" />
                        <%=Resources.Global.BusinessReport %>

                        <p><%=Resources.Global.BusinessReport_Description %></p>

                        <p><%=Resources.Global.BusinessReport_IncludesIfApplicable %>:</p>

                        <div class="row">
                            <div class="col-md-6 col-sm-12 nopadding_lr">
                                <ul class="bulletList">
                                    <%=Resources.Global.BusinessReport_Includes_LeftCol %>
                                </ul>
                            </div>
                            <div class="col-md-6 col-sm-12 nopadding_lr">
                                <ul class="bulletList">
                                    <%=Resources.Global.BusinessReport_Includes_RightCol %>
                                </ul>
                            </div>
                        </div>

                        <p><%=Resources.Global.RatingInfoProvidedInTablesAndGraphs %></p>

                        <asp:Repeater ID="repBR" runat="server">
                            <HeaderTemplate>
                                <table>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td style="padding: 5px; width: 15px; vertical-align: top;">
                                        <input type="radio" name="rbProductID" id="rbProductID<%# Eval("prod_ProductID") %>" value="<%# Eval("prod_ProductID") %>" <%# GetBRChecked((int)Eval("prod_ProductID")) %> />
                                    </td>
                                    <td style="padding: 5px; vertical-align: top;">
                                        <label for="rbProductID<%# Eval("prod_ProductID") %>"><b><%# GetFormattedCurrency((decimal)Eval("StandardUnitPrice"))%></b> - <%# Eval("prod_Name") %></label><br />
                                        <table>
                                            <tr>
                                                <td style="vertical-align: top; width: 500px">
                                                    <%# Eval("prod_PRDescription")%>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>
                    <div class="col-md-5 col-sm-12 vtop">
                        <asp:PlaceHolder ID="contactInfo" runat="server">
                            <div class="form-group form-inline">
                                <div class="row mar_top_2_imp">
                                    <label for="<% =txtFirstName.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.YourFirstName%>&nbsp;<span class="required">*</span></label>
                                    <div class="col-md-7 col-sm-6">
                                        <asp:TextBox ID="txtFirstName" MaxLength="100" runat="server" CssClass="form-control" Width="100%" TabIndex="10" />
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" ControlToValidate="txtFirstName" ValidationGroup="Required" Display="None" runat="server" />
                                    </div>
                                </div>

                                <div class="row mar_top_2_imp">
                                    <label for="<% =txtLastName.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.YourLastName %>&nbsp;<span class="required">*</span></label>
                                    <div class="col-md-7 col-sm-6">
                                        <asp:TextBox ID="txtLastName" MaxLength="100" runat="server" CssClass="form-control" Width="100%" TabIndex="20" />
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator10" ControlToValidate="txtLastName" ValidationGroup="Required" Display="None" runat="server" />
                                    </div>
                                </div>

                                <div class="row mar_top_2_imp">
                                    <label for="<% =txtSubmitterPhone.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.YourPhoneNumber %>&nbsp;<span class="required">*</span></label>
                                    <div class="col-md-7 col-sm-6">
                                        <asp:TextBox ID="txtSubmitterPhone" MaxLength="25" runat="server" CssClass="form-control" wdith="100%" TabIndex="30" />
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" ControlToValidate="txtSubmitterPhone" ValidationGroup="Required" Display="None" runat="server" />
                                    </div>
                                </div>

                                <div class="row mar_top_2_imp">
                                    <label for="<% =txtSubmitterEmail.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.YourEmailAddress %>&nbsp;<span class="required">*</span></label>
                                    <div class="col-md-7 col-sm-6">
                                        <asp:TextBox ID="txtSubmitterEmail" MaxLength="255" runat="server" CssClass="form-control" Width="100%" TabIndex="40" />
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" ControlToValidate="txtSubmitterEmail" ValidationGroup="Required" Display="None" runat="server" />
                                    </div>
                                </div>
                            </div>
                        </asp:PlaceHolder>

                        <div class="form-group form-inline">
                            <div class="row mar_top_2_imp">
                                <label for="<% =txtCompanyName.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.CompanyName %>&nbsp;<span class="required">*</span></label>
                                <div class="col-md-7 col-sm-6">
                                    <asp:TextBox ID="txtCompanyName" CssClass="form-control" MaxLength="200" Width="100%" runat="server" TabIndex="50"  />
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidatorCN" ControlToValidate="txtCompanyName" ValidationGroup="Required" Display="None" runat="server" />
                                    
                                </div>
                            </div>

                            <asp:Panel ID="pnlTypeofBusiness" Visible="false" runat="server">
                                <div class="row mar_top_2_imp">
                                    <label for="<% =ddlTypeofBusiness.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.TypeOfBusiness %>&nbsp;<span class="required">*</span></label>
                                    <div class="col-md-7 col-sm-6">
                                        <asp:DropDownList ID="ddlTypeofBusiness" runat="server" CssClass="form-control" Width="100%" TabIndex="60" />
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator19" ControlToValidate="ddlTypeofBusiness" ValidationGroup="Required" Display="None" runat="server" />
                                    </div>
                                </div>
                            </asp:Panel>

                          

                            <div class="row mar_top_2_imp">
                                <label for="<% =txtNameOnCard.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.NameOnCard %>&nbsp;<span class="required">*</span></label>
                                <div class="col-md-7 col-sm-6">
                                    <asp:TextBox ID="txtNameOnCard" MaxLength="50" tsiRequired="true" runat="server" CssClass="form-control" Width="100%" TabIndex="70"  />
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator15" ControlToValidate="txtNameOnCard" ValidationGroup="Required" Display="None" runat="server" />
                                </div>
                            </div>

                            <div class="row mar_top_2_imp">
                                <label for="<% =txtStreet1.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.BillingAddressLine1%>&nbsp;<span class="required">*</span></label>
                                <div class="col-md-7 col-sm-6">
                                    <asp:TextBox ID="txtStreet1" MaxLength="40" runat="server" CssClass="form-control" Width="100%" TabIndex="80" />
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator5" ControlToValidate="txtStreet1" ValidationGroup="Required" Display="None" runat="server"  />
                                </div>
                            </div>

                            <div class="row mar_top_2_imp">
                                <label for="<% =txtStreet2.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.BillingAddressLine2 %>&nbsp;</label>
                                <div class="col-md-7 col-sm-6">
                                    <asp:TextBox ID="txtStreet2" MaxLength="40" runat="server" CssClass="form-control" Width="100%" TabIndex="90" />
                                </div>
                            </div>

                            <div class="row mar_top_2_imp">
                                <label for="<% =txtCity.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.BillingCity %>&nbsp;<span class="required">*</span></label>
                                <div class="col-md-7 col-sm-6">
                                    <asp:TextBox ID="txtCity" MaxLength="34" runat="server" CssClass="form-control" Width="100%" TabIndex="100" />
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator6" ControlToValidate="txtCity" ValidationGroup="Required" Display="None" runat="server" />
                                </div>
                            </div>

                            <div class="row mar_top_2_imp" id="divCounty" runat="server" visible="false">
                                <label for="<% =txtCounty.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.BillingCounty %></label>
                                <div class="col-md-7 col-sm-6">
                                    <asp:TextBox ID="txtCounty" MaxLength="34" runat="server" CssClass="form-control" Width="100%" TabIndex="110"/>
                                </div>
                            </div>

                            <div class="row mar_top_2_imp">
                                <label for="<% =ddlState.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.BillingStateProvince %>&nbsp;<span class="required">*</span></label>
                                <div class="col-md-7 col-sm-6">
                                    <asp:DropDownList ID="ddlState" runat="server" CssClass="form-control" width="100%" TabIndex="120" />
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator8" ControlToValidate="ddlState" InitialValue="" ErrorMessage="<%$Resources:Global, BillingStateRequired %>" Display="None" runat="server" />
                                    <cc1:CascadingDropDown ID="cddCountry" TargetControlID="ddlCountry" ServiceMethod="GetCountries" Category="Country" runat="server" />
                                    <cc1:CascadingDropDown ID="cddState" TargetControlID="ddlState" ServiceMethod="GetStates" Category="State" ParentControlID="ddlCountry" runat="server" />
                                </div>
                            </div>

                            <div class="row mar_top_2_imp">
                                <label for="<% =ddlCountry.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.BillingCountry %>&nbsp;<span class="required">*</span></label>
                                <div class="col-md-7 col-sm-6">
                                    <asp:DropDownList ID="ddlCountry" runat="server" CssClass="form-control" Width="100%" TabIndex="130" />
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator7" ControlToValidate="ddlCountry" ValidationGroup="Required" Display="None" runat="server"  />
                                </div>
                            </div>

                            <div class="row mar_top_2_imp">
                                <label for="<% =txtPostalCode.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.BillingPostalCode %>&nbsp;<span class="required">*</span></label>
                                <div class="col-md-7 col-sm-6">
                                    <asp:TextBox ID="txtPostalCode" MaxLength="10" runat="server" CssClass="form-control" Width="100%" TabIndex="140" />
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator9" ControlToValidate="txtPostalCode" ValidationGroup="Required" Display="None" runat="server" />
                                </div>
                            </div>
                        </div>

                        <asp:Panel ID="pnlMailingAddress" runat="server" Visible="false">
                            <div class="form-group form-inline">
                                <div class="row mar_top_2_imp">
                                    <label for="<% =cbMailingAddressDifferent.ClientID %>" class="col-md-5 col-sm-6"><%=Resources.Global.MailingAddressDifferentThanBillingAddress %>&nbsp;</label>
                                    <div class="col-md-7 col-sm-12">
                                        <asp:CheckBox ID="cbMailingAddressDifferent" runat="server" Checked="true" AutoPostBack="true" OnCheckedChanged="cbMailingAddressDifferent_CheckedChanged" TabIndex="150" />
                                    </div>
                                </div>
                                <asp:Panel ID="pnlMailingAddressDifferent" runat="server" Visible="true">
                                    <div class="row mar_top_2_imp">
                                        <label for="<% =txtStreet1_Mailing.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.MailingAddressLine1%>&nbsp;<span class="required">*</span></label>
                                        <div class="col-md-7 col-sm-6">
                                            <asp:TextBox ID="txtStreet1_Mailing" MaxLength="40" runat="server" CssClass="form-control" Width="100%" TabIndex="160" />
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator29" ControlToValidate="txtStreet1_Mailing" ValidationGroup="Required" Display="None" runat="server" />
                                        </div>
                                    </div>

                                    <div class="row mar_top_2_imp">
                                        <label for="<% =txtStreet2_Mailing.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.MailingAddressLine2 %>&nbsp;</label>
                                        <div class="col-md-7 col-sm-6">
                                            <asp:TextBox ID="txtStreet2_Mailing" MaxLength="40" runat="server" CssClass="form-control" Width="100%" TabIndex="170" />
                                        </div>
                                    </div>

                                    <div class="row mar_top_2_imp">
                                        <label for="<% =txtCity_Mailing.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.MailingCity %>&nbsp;<span class="required">*</span></label>
                                        <div class="col-md-7 col-sm-6">
                                            <asp:TextBox ID="txtCity_Mailing" MaxLength="34" runat="server" CssClass="form-control" Width="100%" TabIndex="180" />
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator30" ControlToValidate="txtCity_Mailing" ValidationGroup="Required" Display="None" runat="server" />
                                        </div>
                                    </div>

                                    <div class="row mar_top_2_imp">
                                        <label for="<% =ddlState_Mailing.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.MailingStateProvince %>&nbsp;<span class="required">*</span></label>
                                        <div class="col-md-7 col-sm-6">
                                            <asp:DropDownList ID="ddlState_Mailing" runat="server" CssClass="form-control" Width="100%" TabIndex="190" />
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator31" ControlToValidate="ddlState_Mailing" InitialValue="" ErrorMessage="<%$Resources:Global, MailingStateRequired %>" Display="None" runat="server" />
                                            <cc1:CascadingDropDown ID="cddCountry_Mailing" TargetControlID="ddlCountry_Mailing" ServiceMethod="GetCountries" Category="Country" runat="server" />
                                            <cc1:CascadingDropDown ID="cddState_Mailing" TargetControlID="ddlState_Mailing" ServiceMethod="GetStates" Category="State" ParentControlID="ddlCountry_Mailing" runat="server" />
                                        </div>
                                    </div>

                                    <div class="row mar_top_2_imp">
                                        <label for="<% =ddlCountry_Mailing.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.MailingCountry %>&nbsp;<span class="required">*</span></label>
                                        <div class="col-md-7 col-sm-6">
                                            <asp:DropDownList ID="ddlCountry_Mailing" runat="server" CssClass="form-control" Width="100%" TabIndex="200" />
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator32" ControlToValidate="ddlCountry_Mailing" ValidationGroup="Required" Display="None" runat="server" />
                                        </div>
                                    </div>

                                    <div class="row mar_top_2_imp">
                                        <label for="<% =txtPostalCode_Mailing.ClientID %>" class="col-md-5 col-sm-12"><%=Resources.Global.MailingPostalCode %>&nbsp;<span class="required">*</span></label>
                                        <div class="col-md-7 col-sm-6">
                                            <asp:TextBox ID="txtPostalCode_Mailing" MaxLength="10" runat="server" CssClass="form-control" Width="100%" TabIndex="210" />
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator33" ControlToValidate="txtPostalCode_Mailing" ValidationGroup="Required" Display="None" runat="server" />
                                        </div>
                                    </div>
                                </asp:Panel>
                            </div>
                        </asp:Panel>

                        
                    </div>
                    <div class="col-md-7 col-sm-12 vtop" id="divMembership" runat="server">
                        <table class="input" style="width: 600px;">
                            <tr>
                                <td style="vertical-align: top; width: 150px;"><%=Resources.Global.Product %>:</td>
                                <td style="width: 450px;">
                                    <asp:Label ID="lblProduct" runat="server" /></td>
                            </tr>
                            <tr>
                                <td style="width: 150px;"><%=Resources.Global.SubTotal %>:</td>
                                <td style="width: 450px;">
                                    <div class="NumericLabelData">
                                        <asp:Label ID="lblSubTotal" runat="server" />
                                    </div>
                                </td>
                            </tr>

                            <tr>
                                <td style="width: 150px;"><%=Resources.Global.Shipping %>:</td>
                                <td style="width: 450px;">
                                    <div class="NumericLabelData">
                                        <asp:Label ID="lblShipping" runat="server" />
                                    </div>
                                </td>
                            </tr>

                            <tr>
                                <td style="width: 150px;"><%=Resources.Global.SalesTax %>:</td>
                                <td style="width: 450px;">
                                    <div class="NumericLabelData">
                                        <asp:Label ID="lblSalesTax" runat="server" />
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 150px;"><%=Resources.Global.TotalAmount %>:</td>
                                <td style="width: 450px;">
                                    <div class="NumericLabelDataTopBorder">
                                        <asp:Label ID="lblTotal" runat="server" />
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 150px;"></td>
                                <td style="width: 450px;">
                                    <asp:LinkButton ID="btnRecalc" Text="<%$Resources:Global, Recalculate %>" class="button" OnClick="CalculateCharges" Style="width: 110px; font-size: 8pt;" CausesValidation="False" runat="server" /></td>
                            </tr>

                            <tr>
                                <td colspan="2">
                                    <span class="annotation">
                                        <asp:Label Text="Sales tax amount has been updated.<br>" ForeColor="Red" ID="taxUpdated" Visible="false" runat="server" />
                                        <%=Resources.Global.ShippingAndTaxAmountsDependOnLocation %>
                                    </span>
                                </td>
                            </tr>
                        </table>

                        <asp:Panel ID="pnlHowLearned" Visible="false" runat="server">
                            <div class="form-group form-inline">
                                <div class="row mar_top_2_imp vtop">
                                    <label for="<% =ddlHowLearned.ClientID%>" class="col-md-4 col-sm-12"><%=Resources.Global.HowDidYouLearnAboutBlueBookServices %>&nbsp;<span class="required">*</span></label>
                                    <div class="col-md-8 col-sm-6">
                                        <asp:DropDownList ID="ddlHowLearned" Width="100%" runat="server" onchange="produceDetailsChanged();" CssClass="form-control">
                                            <asp:ListItem Text="<%$Resources:Global,TradePublications %>"></asp:ListItem>
                                            <asp:ListItem Text="<%$Resources:Global,Online %>"></asp:ListItem>
                                            <asp:ListItem Text="<%$Resources:Global,IndustryTradeShows %>"></asp:ListItem>
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator18" ControlToValidate="ddlHowLearned" ValidationGroup="Required" Display="None" runat="server" />
                                    </div>
                                </div>

                                <div id="pHowLearnedOther" style="display: none;" class="row mar_top_2_imp vtop" >
                                    <label for="<% =txtProduceHowLearnedOther.ClientID%>" class="col-md-4 col-sm-12"><%=Resources.Global.HowLearnedOther %>&nbsp;<span class="required">*</span></label>
                                    <div class="col-md-8 col-sm-6">
                                        <asp:TextBox ID="txtProduceHowLearnedOther" MaxLength="100" Width="100%" runat="server" CssClass="form-control" />
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator20" ControlToValidate="txtProduceHowLearnedOther" InitialValue="" Display="None" runat="server" />
                                    </div>
                                </div>

                                <div class="row mar_top_2_imp vtop" >
                                    <label for="<% =txtReferralPerson.ClientID%>" class="col-md-4 col-sm-12"><%=Resources.Global.ReferralFromPerson %>:</label>
                                    
                                    <div class="col-md-8 col-sm-6">
                                        <asp:TextBox ID="txtReferralPerson" MaxLength="100" Width="100%" runat="server" CssClass="form-control" />
                                    </div>
                                </div>

                                <div class="row mar_top_2_imp vtop" >
                                    <label for="<% =txtReferralCompany.ClientID%>" class="col-md-4 col-sm-12"><%=Resources.Global.ReferralFromCompany %>:</label>
                                    
                                    <div class="col-md-8 col-sm-6">
                                        <asp:TextBox ID="txtReferralCompany" MaxLength="200" Width="100%" runat="server" CssClass="form-control" />
                                    </div>
                                </div>
                            </div>
                        </asp:Panel>

                        <div class="row">
                            <label for="<% =txtSpecialInstructions.ClientID%>" class="col-md-4 col-sm-12"><%=Resources.Global.SpecialInstructions %>:</label>

                            <div class="col-md-8 col-sm-12">
                                <asp:TextBox ID="txtSpecialInstructions" TextMode="MultiLine" Rows="5" Columns="70" runat="server" CssClass="form-control" />
                            </div>
                        </div>
                    </div>

                    <div class="col-sm-12" id="divBRDelivery" runat="server" visible="false">
                        <div class="row text-center" style="padding-top: 15px">
                            <%=Resources.Global.PleaseProvideValidEmailForBR %>
                        </div>

                        <div class="form-group form-inline">
                            <div class="row mar_top_2_imp">
                                <label for="<% =BREmailAddress.ClientID %>" class="col-md-3 col-md-offset-3 col-sm-12 mar_top_2_imp"><%=Resources.Global.YourEmailAddress %>&nbsp;<span class="required">*</span></label>
                                <div class="col-md-5 col-sm-6">
                                    <asp:TextBox ID="BREmailAddress" MaxLength="255" runat="server" CssClass="form-control" TabIndex="145" />
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator16" ControlToValidate="BREmailAddress" ValidationGroup="Required" Display="None" runat="server" />
                                </div>
                            </div>
                            <div class="row mar_top_2_imp">
                                <label for="<% =BREmailAddressConfirm.ClientID %>" class="col-md-3 col-md-offset-3 col-sm-12"><%=Resources.Global.ConfirmEmailAddress %>&nbsp;<span class="required">*</span></label>
                                <div class="col-md-5 col-sm-6">
                                        <asp:TextBox ID="BREmailAddressConfirm" MaxLength="255" runat="server" CssClass="form-control" TabIndex="147" />
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator17" ControlToValidate="BREmailAddressConfirm" ValidationGroup="Required" Display="None" runat="server" />
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-sm-12 text-center">
                                <p class="cbLabel">
                                    <asp:CheckBox ID="cbMoreInfo" Text="<%$Resources:Global,IWouldLikeMoreInfoAboutBBS %>" runat="server" TabIndex="148" />
                                </p>
                            </div>
                        </div>
                    </div>

                    <asp:Panel ID="pnlMultipleCounties" CssClass="Popup" Style="display: none" Width="350px" runat="server">
                        <%=Resources.Global.SalesTaxPleaseSelectCounty %>:
                        <p style="margin-left: 15px;">
                            <asp:Repeater ID="repCounties" runat="server">
                                <ItemTemplate>
                                    <input type="radio" name="rbCounty" style="margin-right: 3px;" onclick="setCounty('<%# Container.DataItem %>');" /><%# Container.DataItem %><br />
                                </ItemTemplate>
                            </asp:Repeater>
                        </p>
                        <div style="text-align: center">
                            <asp:LinkButton class="button" Style="font-size: 10pt; width: 100px" ID="OkButton2" Visible="false" runat="server" Text="<%$Resources:Global,OK %>" />
                            <asp:LinkButton class="button" Style="font-size: 10pt; width: 100px" ID="OkButton" OnClick="btnPurchaseOnClick" runat="server" Text="<%$Resources:Global,OK %>" />
                            <asp:LinkButton class="button" Style="font-size: 10pt; width: 100px" ID="CancelButton" runat="server" Text="<%$Resources:Global,Cancel %>" />
                        </div>
                    </asp:Panel>

                    <asp:LinkButton ID="btnHidden" OnClientClick="return false;" runat="server" />

                    <cc1:ModalPopupExtender ID="mpeMultipleCounties" runat="server"
                        TargetControlID="btnHidden"
                        PopupControlID="pnlMultipleCounties"
                        BackgroundCssClass="modalBackground"
                        DropShadow="true"
                        CancelControlID="CancelButton" 
                        X="50" 
                        Y="50"
                        
                        />
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>

        <div class="row">
            <div class="col-md-5 col-sm-12 vtop">
                <div class="row mar_top_2_imp">
                    <label for="txtCreditCardNumber" class="col-md-5 col-sm-12"><%=Resources.Global.CreditCardNumber %>&nbsp;<span class="required">*</span></label>
                    <div class="col-md-7 col-sm-6">
                        <input type="text" id="txtCreditCardNumber" name="txtCreditCardNumber" class="form-control" maxlength="20" tabindex="220" />
                        <input type="hidden" id="hidCreditCardNumber" name="hidCreditCardNumber" />
                    </div>
                </div>

                <div class="row mar_top_2_imp">
                    <label for="txtCVV %>" class="col-md-5 col-sm-12"><%=Resources.Global.CVV %>&nbsp;<span class="required">*</span></label>
                    <div class="col-md-7 col-sm-6">
                        <input type="text" id="txtCVV" name="txtCVV" class="form-control" style="width: 30%" maxlength="4" tabindex="230" />
                        <input type="hidden" id="hidCVV" name="hidCVV" />
                        <asp:Label ID="lbWhatIsCVV" Text="<%$Resources:Global, WhatIsThis %>" CssClass="PopupLink" runat="server" />

                        <asp:Panel ID="pnlWhatIsCVV" Style="display: none" CssClass="Popup" Width="400px" runat="server">
                            <%=Resources.Global.CVV_Description %>
                        </asp:Panel>

                        <cc1:PopupControlExtender ID="PopupControlExtender1"
                            runat="server"
                            TargetControlID="lbWhatIsCVV"
                            PopupControlID="pnlWhatIsCVV"
                            Position="Left"
                            OffsetX="-200" />
                    </div>
                </div>

                <div class="row mar_top_2_imp">
                    <label for="txtExpirationMonth" class="col-md-5 col-sm-12 nocursor"><%=Resources.Global.ExpirationDate %>&nbsp;<span class="required">*</span></label>
                    <div class="col-md-7 col-sm-6" style="display: inline-block">
                        <input type="text" id="txtExpirationMonth" name="txtExpirationMonth" maxlength="2" class="form-control" style="width: 70px; display: inline-block" placeholder="MM" tabindex="240" />
                        <input type="hidden" id="hidExpirationMonth" name="hidExpirationMonth" />
                        <input type="text" id="txtExpirationYear" name="txtExpirationYear" maxlength="4" class="form-control" style="width: 70px; display: inline-block" placeholder="YY" tabindex="250" />
                        <input type="hidden" id="hidExpirationYear" name="hidExpirationYear" />
                    </div>
                </div>
            </div>
        </div>

        <p style="color: red;"><%=Resources.Global.FieldsMarkedAsteriskRequired %></p>

        <asp:Panel Style="width: 80%; margin-left: auto; margin-right: auto; margin-top: 15px;" Visible="false" ID="pnlAgreement" runat="server">
            <div style="height: 200px; overflow: auto; border: thin solid gray; font-size: 9pt; padding: 2px;">
                <asp:Literal ID="agreementText" runat="server" />
            </div>

            <p>
                <input type="checkbox" style="vertical-align: middle; margin-right: 5px;" id="cbAgreement" />
                <strong><label for="cbAgreement"><%=Resources.Global.IAgreeToBBMembershipAgreement %></label></strong>
            </p>
            <p><%=Resources.Global.ToPurchaseYouMustAgreeToTerms %></p>
        </asp:Panel>

        <div class="row text-center mar_top_25">
            <div class="g-recaptcha" data-sitekey='<%=ReCaptchaSiteKey()%>' style="display:inline-block" data-callback="setPurchasButtonState" data-expired-callback="setPurchaseButtonState"></div>
        </div>

        <div class="row text-center">
            <asp:LinkButton ID="btnPrevious" Text="<%$ Resources:Global,Previous %>" class="button mar_top_0" OnClick="btnPreviousOnClick" Style="font-size: 10pt; width: 100px" CausesValidation="False" Visible="false" runat="server" />
            <input type="submit" id="btnPurchase" name="btnPurchase" value="Purchase" class="button mar_top_0" style="font-size: 10pt; width: 100px" />
            <asp:Label ID="lblPurchase" runat="server" Visible="false" Text="<%$ Resources:Global,Purchase %>" />

            <asp:HyperLink ID="btnCancel" Text="<%$ Resources:Global,Cancel %>" class="button mar_top_0" Target="_top" Style="font-size: 10pt; width: 100px" runat="server" />
        </div>
        
        <input type="hidden" name="hfStripeToken" id="hfStripeToken" />
    </div>
</asp:Content>