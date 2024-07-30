<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TESLongForm.ascx.cs" Inherits="PRCo.BBOS.UI.Web.TESLongForm" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<script type="text/javascript">
    function submitSurvey() {
        btnSubmitSurveyOnClick();
    }
</script>

<asp:HiddenField ID="hidTESSubjectCompanyID" runat="server" />
<asp:HiddenField ID="hidTESSubjectCompanyName" runat="server" />

<!-- Trade Experience Survey Modal-->
<asp:Panel ID="pnlModalTradeExperienceSurvey" runat="server" Style="display: none; padding:0; font-size: 9pt; overflow-y:auto;" CssClass="Popup" Width="80%" Height="85%">
    <h4 class="blu_tab nomargin row tw-sticky tw-p-4 " style="top:0"><% =Resources.Global.RateCompany%> BB #<% =SubjectCompanyID%>&nbsp;<%=SubjectCompanyNameLocation %></h4>

    <div class="row nomargin tw-p-4">
        <div class="col-xs-12 nomargin_lr">
            <asp:CheckBox ID="cbOutOfBusiness" Text="<%$ Resources:Global, TESGoneOutOfBusiness%>" runat="server" CssClass="space" />
        </div>
    </div>

    <div class="row nomargin tw-grid md:tw-grid-cols-2 tw-p-4">
        <%--COL 1--%>
        <div>
            <div class="row mar_bot_5">
                <label class="bbos_blue nomargin_bottom" for="<%=rbDealtLength.ClientID %>"><% =Resources.Global.TESHowLong%></label>
                <asp:RadioButtonList ID="rbDealtLength" RepeatDirection="vertical" runat="server" CssClass="space rblCompact" />
            </div>
            <div class="row mar_bot_5">
                <label class="bbos_blue nomargin_bottom" for="<%=rbDealtRecently.ClientID %>"><% =Resources.Global.TESHowRecent%></label>
                <asp:RadioButtonList ID="rbDealtRecently" RepeatDirection="vertical" runat="server" CssClass="space rblCompact" />
            </div>

            <asp:Panel ID="pnlNonLumber1" runat="server">
                <div class="row mar_bot_5">
                    <label class="bbos_blue nomargin_bottom" for="<%=rbDealRegularly.ClientID %>"><% =Resources.Global.TESDealRegularly%></label>
                    <asp:RadioButtonList ID="rbDealRegularly" RepeatDirection="vertical" runat="server" CssClass="space rblCompact" />
                </div>

                <div class="row mar_bot_5">
                    <label class="bbos_blue nomargin_bottom" for="<%=rbIntegrity.ClientID %>"><% =Resources.Global.TESIntegrity%></label>
                    <asp:RadioButtonList ID="rbIntegrity" RepeatDirection="vertical" runat="server" Width="100%" CssClass="space rblCompact" />
                </div>

                <div class="row mar_bot_5">
                    <label class="bbos_blue nomargin_bottom" for="<%=rbPay.ClientID %>"><% =Resources.Global.TESPay%></label>
                    <asp:RadioButtonList ID="rbPay" RepeatDirection="vertical" Width="100%" runat="server" CssClass="space rblCompact" />
                </div>
            </asp:Panel>
        </div>

        <%--COL 2--%>
        <div>
            <div class="row nomargin tw-grid md:tw-grid-cols-2 tw-p-4">
                <div>
                    <asp:Panel ID="pnlNonLumber2" runat="server">
                        <div class="row mar_bot_5">
                            <label class="bbos_blue nomargin_bottom" for="<%=rbHighCredit.ClientID %>"><% =Resources.Global.TESHighCredit%></label>
                            <asp:RadioButtonList ID="rbHighCredit" RepeatDirection="vertical" Width="60%" runat="server" CssClass="space rblCompact" />
                        </div>
                        <div class="row mar_bot_5">
                            <label class="bbos_blue nomargin_bottom" for="<%=cbTerms.ClientID %>"><% =Resources.Global.TESTerms%></label>
                            <asp:CheckBoxList ID="cbTerms" RepeatDirection="vertical" runat="server" CssClass="space rblCompact" />
                        </div>
                    </asp:Panel>

                    <div class="row mar_bot_5">
                        <label class="bbos_blue nomargin_bottom" for="<%=rbTrend.ClientID %>"><% =Resources.Global.TESTrend%></label>
                        <asp:RadioButtonList ID="rbTrend" RepeatDirection="vertical" runat="server" CssClass="space rblCompact" />
                    </div>
                </div>
                <div>
                    <div class="row mar_bot_5">
                        <label class="bbos_blue nomargin_bottom" for="<%=rbPastDue.ClientID %>"><% =Resources.Global.TESPastDue%></label>
                        <asp:RadioButtonList ID="rbPastDue" RepeatDirection="vertical" runat="server" CssClass="space rblCompact" />
                    </div>

                    <div class="row mar_bot_5">
                        <label class="bbos_blue nomargin_bottom" for="<%=rbDispute.ClientID %>"><% =Resources.Global.TESDispute%></label>
                        <asp:RadioButtonList ID="rbDispute" RepeatDirection="vertical" runat="server" CssClass="space rblCompact" />
                    </div>

                    <div class="row mar_bot_5">
                        <label class="bbos_blue nomargin_bottom" for="<%=rbInvoice.ClientID %>"><% =Resources.Global.TESInvoice%></label>
                        <asp:RadioButtonList ID="rbInvoice" RepeatDirection="vertical" runat="server" CssClass="space rblCompact" />
                    </div>

                    <div class="row mar_bot_5">
                        <label class="bbos_blue nomargin_bottom" for="<%=rbCreditTerms.ClientID %>"><% =Resources.Global.TESCreditTerms%></label>
                        <asp:RadioButtonList ID="rbCreditTerms" RepeatDirection="vertical" runat="server" CssClass="space rblCompact" />
                        <asp:TextBox ID="txtCreditTerms" Columns="25" MaxLength="40" Visible="false" runat="server" CssClass="form-control" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlLumber" runat="server" CssClass="nomargin tw-p-4">
        <div class="row nomargin">
            <div class="col-xs-12 nopadding">
                <label class="bbos_blue nomargin_bottom"><% =Resources.Global.TESAmountOwed%></label>
            </div>
        </div>
        <div class="row nomargin">
            <div class="col-xs-2 nopadding">
                Current:
            </div>
            <div class="col-xs-4">
                $<asp:TextBox ID="txtAmountOwedCurrent" Columns="10" MaxLength="10" runat="server" tsiCurrency="true" CssClass="TextBoxNumeric" />
            </div>
        </div>
        <div class="row nomargin">
            <div class="col-xs-2 nopadding">
                1-30 days past due:
            </div>
            <div class="col-xs-4">
                $<asp:TextBox ID="txtAmountOwed1_30" Columns="10" MaxLength="10" runat="server" tsiCurrency="true" CssClass="TextBoxNumeric" />
            </div>
        </div>
        <div class="row nomargin">
            <div class="col-xs-2 nopadding">
                31-60 days past due:
            </div>
            <div class="col-xs-4">
                $<asp:TextBox ID="txtAmountOwed31_60" Columns="10" MaxLength="10" runat="server" tsiCurrency="true" CssClass="TextBoxNumeric" />
            </div>
        </div>
        <div class="row nomargin">
            <div class="col-xs-2 nopadding">
                61-90 days past due:
            </div>
            <div class="col-xs-4">
                $<asp:TextBox ID="txtAmountOwed61_90" Columns="10" MaxLength="10" runat="server" tsiCurrency="true" CssClass="TextBoxNumeric" />
            </div>
        </div>
        <div class="row nomargin">
            <div class="col-xs-2 nopadding">
                91+ days past due:
            </div>
            <div class="col-xs-4">
                $<asp:TextBox ID="txtAmountOwed91" Columns="10" MaxLength="10" runat="server" tsiCurrency="true" CssClass="TextBoxNumeric" />
            </div>
        </div>

        <cc1:FilteredTextBoxExtender ID="filterTxtAmountOwedCurrent" TargetControlID="txtAmountOwedCurrent" FilterType="Custom, Numbers" ValidChars="." runat="server" />
        <cc1:FilteredTextBoxExtender ID="filterTxtAmountOwed1_30" TargetControlID="txtAmountOwed1_30" FilterType="Custom, Numbers" ValidChars="." runat="server" />
        <cc1:FilteredTextBoxExtender ID="filterTxtAmountOwed31_60" TargetControlID="txtAmountOwed31_60" FilterType="Custom, Numbers" ValidChars="." runat="server" />
        <cc1:FilteredTextBoxExtender ID="filterTxtAmountOwed61_90" TargetControlID="txtAmountOwed61_90" FilterType="Custom, Numbers" ValidChars="." runat="server" />
        <cc1:FilteredTextBoxExtender ID="filterTxtAmountOwed91" TargetControlID="txtAmountOwed91" FilterType="Custom, Numbers" ValidChars="." runat="server" />
    </asp:Panel>



    <div class="row nomargin tw-p-4">
        <div class="col-xs-8 nopadding">
            <label class="bbos_blue nomargin_bottom" for="<%=txtComments.ClientID %>"><% =Resources.Global.Comments%></label>
            <asp:TextBox ID="txtComments" Columns="40" Rows="1" TextMode="MultiLine" runat="server" CssClass="form-control" />
        </div>
    </div>

    <div class="row nomargin tw-sticky tw-bg-bg-primary tw-p-4 tw-border-t tw-border-border tw-flex tw-gap-4 tw-justify-end" style="bottom:0">
        <asp:LinkButton id="btnCancelSurvey" runat="server" CssClass="bbsButton bbsButton-secondary" OnClick="btnSubmitSurveyOnClick">
            <span class="msicon notranslate">close</span>
            <div class="text-content">
                <span class="label"><asp:Literal runat="server" Text="<%$Resources:Global, btnCancel %>" /></span>
            </div>
        </asp:LinkButton>
        <asp:LinkButton id="btnSubmitSurvey" runat="server" CssClass="bbsButton bbsButton-primary" OnClick="btnSubmitSurveyOnClick">
            <span class="msicon notranslate">send</span>
            <div class="text-content">
                <span class="label"><asp:Literal runat="server" Text="<%$Resources:Global, Submit %>" /></span>
            </div>
        </asp:LinkButton>
    </div>
</asp:Panel>

<cc1:ModalPopupExtender ID="mdlExtTradeExperienceSurvey" runat="server" OnOkScript="submitSurvey()"
    TargetControlID="btnRateCompany"
    PopupControlID="pnlModalTradeExperienceSurvey" OkControlID="btnSubmitSurvey" CancelControlID="btnCancelSurvey"
    BackgroundCssClass="modalBackground" BehaviorID="mpeTESSurvey" />
