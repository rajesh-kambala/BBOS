<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BusinessReportConfirmSelections.aspx.cs" EnableEventValidation="false" Inherits="PRCo.BBOS.UI.Web.BusinessReportConfirmSelections" MasterPageFile="~/BBOS.Master" MaintainScrollPositionOnPostback="true" %>

<%@ Register Src="~/UserControls/CreditCardInput.ascx" TagName="CreditCardInput" TagPrefix="BBOS" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
       

        $('document').ready(function () {

            Stripe.setPublishableKey("<%= Utilities.GetConfigValue("Stripe_Publishable_Key")%>");

            $('#btnChargeCreditCard').on('click', function (e) {
                bEnableValidation = true;
                preStdValidation(document.forms[0]);
                if (!validateForm(document.forms[0]))
                    return false;
                $('#btnChargeCreditCard').attr('tsiDisable', 'true');

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

            function Clear() {
                $('#txtCreditCardNumber').val('');
                $('#txtCVV').val('');
                $('#txtExpirationMonth').val('');
                $('#txtExpirationYear').val('');
            }

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
        });
    </script>

    <script src="https://js.stripe.com/v2/"></script>

    <style>
        .row.Title b {
            width: auto;
            padding: 0;
            padding-left: 5px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:HiddenField ID="hidTriggerPage" runat="server" />
    <asp:HiddenField ID="hidTotal" runat="server" />
    <asp:HiddenField ID="hidRemainingUnits" runat="server" />

    <div class="row nomargin panels_box" style="min-height:600px">
        <div class="col-md-12">
            <div class="row Title" style="margin-bottom: 15px;">
                <asp:Literal ID="litHeaderText" runat="server"></asp:Literal>
                <% =Resources.Global.ConfirmSelectionsBelow %>

                <div class="row bold mar_top">
                    <asp:Literal ID="litSelectText" runat="server"></asp:Literal>
                </div>

                <asp:Panel ID="pnlMember" runat="server">
                    <div class='row'>
                        <div class='col-md-12'>
                            <b><asp:Literal ID="litMemberReportTitle" runat="server" /></b>
                            <a id="popMemberReportTitle" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                                <img src="images/info_sm.png" />
                            </a>
                        </div>
                    </div>

                    <div class='row'>
                        <div class='col-md-12'>
                            <asp:Literal ID="litMemberReportType" runat="server" />
                        </div>
                    </div>

                    <asp:Panel ID="pnlLimitadoPurchaseInfo" runat="server" Visible="false">
                        <div class="row mar_top">
                            <div class="col-md-12">
                                <asp:Literal ID="litLimitadoPurchaseInfo" runat="server"></asp:Literal>
                            </div>
                        </div>
                    </asp:Panel>

                    <asp:RadioButtonList ID="rblMemReportType" runat="server" AutoPostBack="True" OnSelectedIndexChanged="rblMemReportType_SelectedIndexChanged" CssClass="form-control" />
                    <div class="row mar_top mar_bot">
                        <div class="col-md-12">
                            <i><asp:Literal ID="litMemDescription" runat="server" Text="<%$ Resources:Global, MembershipDescriptionNote %>" /></i>
                        </div>
                    </div>
                </asp:Panel>

                <div style="text-align: center;">
                    <img src="<% =UIUtils.GetImageURL("fileicon-pdf.gif") %>" alt="" style="display:inline;" />
                    <asp:HyperLink ID="hlBusinessReportSample" Target="winBRSample" runat="server" CssClass="explicitlink" />
                </div>
            </div>

            <div class="row">
                <asp:Label ID="lblRecordCount" runat="server" CssClass="RecordCnt" />
            </div>

            <div class="row">
                <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                    <ContentTemplate>
                        <asp:GridView ID="gvSelectedCompanies"
                            AllowSorting="true"
                            runat="server"
                            AutoGenerateColumns="false"
                            CssClass="sch_result table table-striped table-hover"
                            GridLines="none"
                            OnSorting="GridView_Sorting"
                            OnRowDataBound="GridView_RowDataBound"
                            SortField="comp_PRBookTradestyle"
                            DataKeyNames="comp_CompanyID"
                            ShowFooter="true">

                            <Columns>
                                <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap" ItemStyle-CssClass="text-left" DataField="comp_CompanyID" SortExpression="comp_CompanyID" />

                                <%--Icons Column--%>
                                <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
                                    <ItemTemplate>
                                        <%# GetCompanyDataForCell((int)Eval("comp_CompanyID"), 
                                                        (string)Eval("comp_PRBookTradestyle"), 
                                                        (string)Eval("comp_PRLegalName"), 
                                                        UIUtils.GetBool(Eval("HasNote")), 
                                                        UIUtils.GetDateTime(Eval("comp_PRLastPublishedCSDate")), 
                                                        (string)Eval("comp_PRListingStatus"), 
                                                        true, 
                                                        UIUtils.GetBool(Eval("HasNewClaimActivity")), 
                                                        UIUtils.GetBool(Eval("HasMeritoriousClaim")), 
                                                        UIUtils.GetBool(Eval("HasCertification")), 
                                                        UIUtils.GetBool(Eval("HasCertification_Organic")), 
                                                        UIUtils.GetBool(Eval("HasCertification_FoodSafety")), 
                                                        true, 
                                                        false)%>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <%--Company Name column--%>
                                <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-left" HeaderText="<%$ Resources:Global, CompanyName %>"
                                    SortExpression="comp_PRBookTradestyle">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:BoundField HeaderText="<%$ Resources:Global, Location %>"
                                    ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left" DataField="CityStateCountryShort"
                                    SortExpression="CityStateCountryShort" />

                                <asp:BoundField HeaderText="<%$ Resources:Global, Industry %>"
                                    ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left" DataField="IndustryType"
                                    SortExpression="IndustryType" />

                                <%--Type/Industry Column--%>
                                <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" ItemStyle-CssClass="text-left vertical-align-top" SortExpression="CompanyType">
                                    <HeaderTemplate>
                                        <asp:LinkButton ID="lbTypeIndustryColHeader" runat="server" Text='<%$ Resources:Global, Type %>' CommandName="Sort" CommandArgument="CompanyType" />
                                        &nbsp;
                                        <a id="popWhatIsIndustry" runat="server" class="clr_blc cursor_pointer" data-bs-html="true" style="color: #000;" data-bs-toggle="modal" data-bs-target="#pnlIndustry">
                                            <asp:Image runat="server" ImageUrl="images/info_sm.png" ToolTip="<%$ Resources:Global, WhatIsThis %>" />
                                        </a>
                                    </HeaderTemplate>

                                    <ItemTemplate>
                                        <%# PageControlBaseCommon.GetCompanyType((string)Eval("CompanyType"), Eval("comp_PRLocalSource"))%>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderStyle-CssClass="text-nowrap" HeaderText="<%$ Resources:Global, Price %>">
                                    <ItemTemplate>
                                        $30.00
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-right" HeaderText="" ItemStyle-CssClass="text-right">
                                    <ItemTemplate>
                                        <%# GetAvailability((int)Eval("comp_CompanyID"))%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>

                        <div id="pnlIndustry" class="modal fade" role="dialog">
                            <div class="modal-dialog">
                                <!-- Modal content-->
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" data-bs-dismiss="modal">&times;</button>
                                    </div>
                                    <div class="modal-body">
                                        <span class="sml_font">
                                            <%= Resources.Global.IndustryHelp %>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <asp:Panel ID="pnlMemFooter" runat="server" CssClass="mar_bot">
                            <div class="row shaderow nomargin">
                                <div class="col-md-4 bold text-nowrap form-inline">
                                    <% =Resources.Global.AvailableServiceUnits %>:
                                    <asp:Literal ID="litAvailableUnits" runat="server" />
                                </div>
                            </div>

                            <div class="row shaderow nomargin">
                                <div class="col-md-4 bold text-nowrap form-inline">
                                    <% =Resources.Global.BusinessReportsRemainingAfterPurchase %>:
                                    <asp:Literal ID="litRemainingUnits" runat="server" />
                                </div>
                            </div>
                        </asp:Panel>

                        <asp:Label ID="lblNotEnoughUnits" runat="server" />

                        <asp:Panel ID="pnlCreditCardInput" runat="server" Visible="false">
                            <BBOS:CreditCardInput ID="ucCCI" runat="server" BillingCountyVisible="false" />

                            <div class="row mar_top">
                                <div class="col-md-10 offset-md-2">
                                    <% =PageBase.GetRequiredFieldMsg() %>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-2 clr_blu text-nowrap">
                                    <% =Resources.Global.Product %>:
                                </div>
                                <div class="col-md-10">
                                    <asp:Label ID="lblProduct" runat="server"/>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-2 clr_blu text-nowrap">
                                    <% =Resources.Global.TotalAmount %>:
                                </div>
                                <div class="col-md-10">
                                    <asp:Literal ID="lblTotal" runat="server" />
                                </div>
                            </div>

                        </asp:Panel>

                        <div class="row">
                            <asp:Label CssClass="validationError" ID="errMsg" runat="server" />
                        </div>

                        <div class="row nomargin_lr text-left mar_top">
                            <asp:LinkButton ID="btnPurchase" runat="server" CssClass="btn gray_btn" OnClick="btnPurchase_Click" Visible="false">
	                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, GetReport %>" />
                            </asp:LinkButton>

                            <asp:LinkButton ID="btnChargeCreditCard" runat="server" CssClass="btn gray_btn" OnClick="btnChargeCreditCard_Click">
	                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, GetReport%>" />
                            </asp:LinkButton>
                            <!--input type="submit" id="btnChargeCreditCard" name="btnChargeCreditCard" value="Get Report" class="btn gray_btn" Visible="false" /-->

                            <asp:LinkButton ID="btnReviseSelections" runat="server" CssClass="btn gray_btn" OnClick="btnReviseSelections_Click">
	                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, ReviseSelections %>" />
                            </asp:LinkButton>

                            <asp:LinkButton ID="btnHome" runat="server" CssClass="btn gray_btn" OnClick="btnHome_Click">
    	                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Home %>" />
                            </asp:LinkButton>
                        </div>

                        <asp:Panel ID="pnlMemFooter2" runat="server">
                            <div class="row nomargin_lr text-left">
                                <asp:LinkButton ID="btnPurchaseAdditionalUnits" runat="server" CssClass="btn gray_btn" OnClick="btnPurchaseAdditionalOnClick">
	                                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, PurchaseAdditionalReports %>" />
                                </asp:LinkButton>
                            </div>
                        </asp:Panel>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="rblMemReportType" EventName="SelectedIndexChanged" />
                    </Triggers>
                </asp:UpdatePanel>
            </div>
        </div>
    </div>

    <input type="hidden" name="hfStripeToken" id="hfStripeToken" />
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        bEnableValidation = false;
    </script>
</asp:Content>