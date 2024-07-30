<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="UserProfile.aspx.cs" Inherits="PRCo.BBOS.UI.Web.UserProfile" EnableEventValidation="false" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="bbos" TagName="EMCW_CompanyHeader" Src="~/UserControls/EMCW_CompanyHeader.ascx" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        function preStdValidation(form) {
            if (ddlState == undefined) {
                return true;
            }

            if (ddlState.options.length == 1) {
                ddlState.removeAttribute("tsiRequired");
            } else {
                ddlState.setAttribute("tsiRequired", "true");
            }

            return true;
        }
    </script>

    <style type="text/css">
        .description {
            font-style: italic;
            padding-bottom: 10px;
        }

        .divider {
            padding-bottom: 0;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <bbos:EMCW_CompanyHeader ID="ucCompanyDetailsHeader" runat="server" />

    <asp:Label ID="ReturnURL" Visible="false" runat="server" />
    <asp:Label ID="lblIsMembership" Visible="false" runat="server" />

    <div class="row mar_top" id="divWelcomeMsg" runat="server">
        <div class="col-md-12 text-left clr_blu">
            <%= Resources.Global.IfNeededChangeBBOSAccountThenSave %>
            <br />
            <asp:Literal ID="litWelcomeMsg" runat="server" />
        </div>
    </div>

    <asp:Panel ID="fsUserInfo" Style="width: 100%" CssClass="box_left" runat="server">
        <div class="row panels_box">
            <div class="col-md-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h4 class="blu_tab">
                            <asp:Label ID="lblUserInfo" runat="server" />
                        </h4>
                    </div>
                    <div class="panel-body nomargin pad10">
                        <div class="row">
                            <div class="col-md-2">
                                <div class="clr_blu"><% =Resources.Global.EmailAddress %>:</div>
                            </div>
                            <div class="col-md-3">
                                <asp:Label ID="lblEmail" runat="server" />
                            </div>
                            <div class="col-md-7 description">
                                <%= Resources.Global.ChangeLoginEmailContactMsg %>&nbsp;<a href="mailto:customersuccess@bluebookservices.com" class="explicitlink">customersuccess@bluebookservices.com</a>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-2">
                                <div class="clr_blu"><% =Resources.Global.NewPassword %>:</div>
                            </div>
                            <div class="col-md-3">
                                <asp:TextBox ID="txtPassword" TextMode="Password" MaxLength="20" tsiDisplayName="<%$ Resources:Global, NewPassword %>" runat="server" CssClass="form-control" />
                                <asp:Literal ID="litPasswordReq" runat="server" />
                            </div>
                            <div class="col-md-7">
                                <cc1:PasswordStrength ID="psPassword" runat="server"
                                    TargetControlID="txtPassword"
                                    DisplayPosition="RightSide"
                                    StrengthIndicatorType="Text"
                                    PreferredPasswordLength="10"
                                    PrefixText="Strength:"
                                    TextStrengthDescriptions="Weak;Average;Strong;Excellent"
                                    TextStrengthDescriptionStyles="PasswordStrengthWeak;PasswordStrengthAverage;PasswordStrengthStrong;PasswordStrengthExcellent"
                                    RequiresUpperAndLowerCaseCharacters="false" />
                            </div>
                        </div>

                        <div class="row mar_top_5">
                            <div class="col-md-2">
                                <div class="clr_blu"><% =Resources.Global.ConfirmNewPassword %>:</div>
                            </div>
                            <div class="col-md-3">
                                <asp:TextBox ID="txtConfirmPassword" TextMode="Password" MaxLength="20" tsiDisplayName="<%$ Resources:Global, ConfirmNewPassword %>" runat="server" CssClass="form-control" />
                                <asp:Literal ID="litConfirmPasswordReq" runat="server" />
                            </div>
                        </div>

                        <div class="row mar_top_5">
                            <div class="col-md-2">
                                <div class="clr_blu"><% =Resources.Global.TimeZone %>:</div>
                            </div>
                            <div class="col-md-3">
                                <asp:DropDownList ID="ddlTimeZone" runat="server" CssClass="form-control" />
                            </div>
                            <div class="col-md-7 description">
                                <% =Resources.Global.SetTimeZoneAllowRemindersMsg %>
                            </div>
                        </div>

                        <div class="row" runat="server" visible="false">
                            <div class="col-md-2">
                                <div class="clr_blu"><% =Resources.Global.Language %>:</div>
                            </div>
                            <div class="col-md-3">
                                <asp:DropDownList ID="ddlLanguage" runat="server" CssClass="form-control" />
                                <% =PageBase.GetRequiredFieldIndicator() %>
                            </div>
                        </div>
                        <asp:Panel ID="pnlLumberSettings" Visible="false" runat="server">
                            <div class="row">
                                <div class="col-md-10 offset-md-2">
                                    <asp:CheckBox ID="cbWillSubmitARData" runat="server" CssClass="space"
                                        Text='<%$ Resources:Global, CompanyWillingToSubmitARAgingData %>' />
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-10 offset-md-2">
                                    <asp:CheckBox ID="cbReceiveCreditSheetReport" runat="server" CssClass="space"
                                        Text='<%$ Resources:Global, ReceiveCreditSheetReportViaEmails %>' />
                                </div>
                            </div>
                        </asp:Panel>

                        <div class="row mar_top">
                            <div class="col-md-12">
                                <asp:LinkButton ID="LinkButton1" runat="server" CssClass="btn gray_btn" OnClick="btnRegisterOnClick">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnSave %>" />
                                </asp:LinkButton>
                                <asp:LinkButton ID="LinkButton2" runat="server" CssClass="btn gray_btn" OnClick="btnCancelOnClick">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnCancel %>" />
                                </asp:LinkButton>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="fsCompanySearchSettings" Style="width: 100%;" CssClass="box_left" runat="server">
        <div class="row panels_box">
            <div class="col-md-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h4 class="blu_tab">
                            <%= Resources.Global.BBOSSettings%>
                        </h4>
                    </div>
                    <div class="panel-body nomargin pad10">
                        <div class="row mar_top_5" id="trLocalSource" visible="false" runat="server">
                            <div class="col-md-3">
                                <div class="clr_blu"><% =Resources.Global.DefaultCompanyLocalSourceData %>:</div>
                            </div>
                            <div class="col-md-3">
                                <asp:DropDownList ID="ddlLocalSourceSearch" runat="server" CssClass="form-control" />
                            </div>
                            <div class="col-md-6 description">
                                <%= Resources.Global.DetermineIfLocalSouceDataIsByDefault %>
                            </div>
                        </div>

                        <div class="row mar_top_5" id="trARReports" runat="server">
                            <div class="col-md-3">
                                <div class="clr_blu"><% =Resources.Global.DefaultARReportHistoryGrid %>:</div>
                            </div>
                            <div class="col-md-3">
                                <asp:DropDownList ID="ddlARReports" runat="server" CssClass="form-control" />
                            </div>
                            <div class="col-md-6 description">
                                <%= Resources.Global.ChooseHowManyMonthsofARReportHistoryToDisplay %>
                            </div>
                        </div>

                        <div class="row mar_top_5" id="fsCompanyUpdateDaysOld" visible="false" runat="server">
                            <div class="col-md-3">
                                <div class="clr_blu"><% =Resources.Global.CompanyUpdateSearchDaysOld %>:</div>
                            </div>
                            <div class="col-md-1">
                                <asp:TextBox ID="txtCompanyUpdateDaysOld" MaxLength="3" runat="server" CssClass="form-control" />
                                <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender1" TargetControlID="txtCompanyUpdateDaysOld" FilterType="Numbers" runat="server"></cc1:FilteredTextBoxExtender>
                            </div>
                            <div class="col-md-6 offset-md-2 description">
                                <%= Resources.Global.NumberReflectsDaysWorthOFUpdatesWithinMessageCenter %>
                            </div>
                        </div>

                        <div class="row mar_top_5">
                            <div class="col-md-3">
                                <div class="clr_blu"><% =Resources.Global.UpdatesShowninMessageCenter %>:</div>
                            </div>
                            <div class="col-md-3">
                                <asp:DropDownList ID="ddlCompanyUpdateMessageType" runat="server" CssClass="form-control" />
                            </div>
                            <div class="col-md-6 description">
                                <%= Resources.Global.ShowEitherAllUpdatesorKeyUpdates %>
                            </div>
                        </div>

                        <div class="row mar_top_5">
                            <div class="col-md-3">
                                <div class="clr_blu"><% =Resources.Global.AutomaticallyEmailPurchases %>:</div>
                            </div>
                            <div class="col-md-3">
                                <asp:CheckBox ID="cbEmailPurchases" runat="server" CssClass="space" />
                            </div>
                            <div class="col-md-6 description">
                                <%= Resources.Global.SelectIfWantBusinessReportsSentToEmailAuto %>
                            </div>
                        </div>

                        <div class="row mar_top_5">
                            <div class="col-md-3">
                                <div class="clr_blu"><% =Resources.Global.SendAsZipFile%>:</div>
                            </div>
                            <div class="col-md-3">
                                <asp:CheckBox ID="cbCompressEmailedPurchases" runat="server" CssClass="space" />
                            </div>
                            <div class="col-md-6 description">
                                <%= Resources.Global.SelectIfWantBusinessReportsSentToEmailAsZipAuto %>
                            </div>
                        </div>

                        <div class="row mar_top_5">
                            <div class="col-md-3">
                                <div class="clr_blu"><% =Resources.Global.CompanyLinksInNewTab%>:</div>
                            </div>
                            <div class="col-md-3">
                                <asp:CheckBox ID="cbCompanyLinksInNewTab" runat="server" CssClass="space" />
                            </div>
                            <div class="col-md-6 description">
                                <%= Resources.Global.CompanyLinksInNewTabDescription %>
                            </div>
                        </div>

                        <div class="row mar_top_5">
                            <div class="col-md-3">
                                <div class="clr_blu"><% =Resources.Global.HideBRPurchaseConfirmationMsg%>:</div>
                            </div>
                            <div class="col-md-3">
                                <asp:CheckBox ID="cbHideBRPurchConfMsg" runat="server" CssClass="space" />
                            </div>
                            <div class="col-md-6 description">
                                <%= Resources.Global.HideBRPurchaseConfirmationMsgDescription %>
                            </div>
                        </div>

                        <div class="row" style="display: none;">
                            <div class="col-md-3">
                                <div class="clr_blu"><% =Resources.Global.LinkedInAuth%>:</div>
                            </div>
                            <div class="col-md-3">
                                <asp:HyperLink ID="btnEditSocialMedia" Visible="false" Text="Edit LinkedIn Authorization" NavigateUrl="~/UserSocialMedia.aspx" CssClass="SmallButton" Style="float: none;" runat="server" />
                            </div>
                            <div class="col-md-6 description">
                                <%= Resources.Global.ClickToAllowAccessToLinkedInProfile %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="fsAlertsSettings" Style="width: 100%;" CssClass="box_left" runat="server">
        <div class="row panels_box">
            <div class="col-md-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h4 class="blu_tab">
                            <%= Resources.Global.AlertsSettings%>
                        </h4>
                    </div>
                    <div class="panel-body nomargin pad10">
                        <div class="row">
                            <div class="col-md-2">
                                <div class="clr_blu"><% =Resources.Global.DeliveryMethod %>:</div>
                            </div>
                            <div class="col-md-4">
                                <asp:RadioButtonList ID="rbDeliveryMethod" runat="server" RepeatDirection="vertical" CssClass="space" />
                            </div>
                            <div class="col-md-6 description">
                                <asp:Literal ID="NoFax" runat="server" /><%= Resources.Global.ChooseWayReceiveAlertsReport %>
                            </div>
                        </div>

                        <div class="row" id="divEmail">
                            <div class="col-md-2">
                                <div class="clr_blu"><% =Resources.Global.DeliveryMethodEmail %>:</div>
                            </div>
                            <div class="col-md-4 form-inline">
                                <asp:RadioButtonList ID="rbDeliveryMethodEmail" runat="server" RepeatDirection="Vertical" CssClass="space" />
                                <asp:HiddenField ID="hidRegisteredUserEmail" runat="server" />
                                <asp:HiddenField ID="hidPeli_PRAlertEmail" runat="server" />
                            </div>
                            <div class="col-md-6 description">
                                <asp:Literal ID="Literal1" runat="server" />
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-2">
                                <div class="clr_blu"><% =Resources.Global.KeyChangesOnly %>:</div>
                            </div>
                            <div class="col-md-4">
                                <asp:CheckBox ID="cbAUSKeyOnly" runat="server" />
                            </div>
                            <div class="col-md-6 description">
                                <asp:Literal ID="ltWhatIsKeyChanges" runat="server" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="fsCSSettings" Style="width: 100%;" CssClass="box_left" runat="server">
        <div class="row panels_box">
            <div class="col-md-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h4 class="blu_tab">
                            <asp:Literal ID="headCSProductName" runat="Server" />
                            <%= Resources.Global.Settings%>
                        </h4>
                    </div>
                    <div class="panel-body nomargin pad10">
                        <div class="row">
                            <div class="col-md-2">
                                <div class="clr_blu"><% =Resources.Global.DeliveryMethod %>:</div>
                            </div>
                            <div class="col-md-4">
                                <asp:RadioButtonList ID="rbCSDeliveryMethod" runat="server" RepeatDirection="vertical" CssClass="space" />
                            </div>
                            <div class="col-md-6 description">
                                <asp:Literal ID="CSNoFax" runat="server" /><%= Resources.Global.ChooseWayReceiveYour %>
                                <asp:Literal ID="receiveCSProductName" runat="Server" />.
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-2">
                                <div class="clr_blu"><% =Resources.Global.SortOption %>:</div>
                            </div>
                            <div class="col-md-4">
                                <asp:DropDownList ID="ddlCSSortOption" runat="server" CssClass="form-control" />
                            </div>
                            <div class="col-md-6 description">
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="fsEmailSettings" Style="width: 100%;" CssClass="box_left" runat="server">
        <div class="row panels_box">
            <div class="col-md-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h4 class="blu_tab">
                            <%= Resources.Global.OptInToBBServicesEmails%>
                        </h4>
                    </div>
                    <div class="panel-body nomargin pad10">
                        <div class="row">
                            <div class="col-md-12 description">
                                <%= Resources.Global.UncheckBoxesToOptOutEmails%>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-5 text-nowrap">
                                <div class="clr_blu"><% =Resources.Global.ReceivesTrainingEmail %>?</div>
                            </div>
                            <div class="col-md-4">
                                <asp:CheckBox ID="cbReceivesTrainingEmail" runat="server" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-5 text-nowrap">
                                <div class="clr_blu"><% =Resources.Global.ReceivesPromoEmail %>?</div>
                            </div>
                            <div class="col-md-4">
                                <asp:CheckBox ID="cbReceivesPromoEmail" runat="server" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-5 text-nowrap">
                                <div class="clr_blu"><% =Resources.Global.ReceiveBusinessReportSurveys %>?</div>
                            </div>
                            <div class="col-md-4">
                                <asp:CheckBox ID="cbReceiveBRSurvey" runat="server" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <asp:UpdatePanel ID="upWidgets" runat="server">
        <ContentTemplate>
            <asp:Panel ID="fsWidgets" Style="width: 100%;" CssClass="box_left" runat="server">
                <a href="#Widgets" class="BookmarkButton" runat="server" />
                <div class="row panels_box">
                    <div class="col-md-12">
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h4 class="blu_tab">
                                    <%= Resources.Global.Widgets%>
                                </h4>
                            </div>
                            <div class="panel-body nomargin pad10">
                                <div class="row">
                                    <div class="col-md-12 description">
                                        <%= Resources.Global.SelectWidgetsForHomeScreen%>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-5 col-md-6 col-sm-6 col-xs-6">
                                        <b>
                                            <asp:Literal runat="server" Text="<% $Resources:Global, WidgetsAvailable %>" /></b>
                                    </div>
                                    <div class="col-lg-5 col-md-6 col-sm-6 col-xs-6">
                                        <b>
                                            <asp:Literal runat="server" Text="<% $Resources:Global, WidgetsSelected%>" /></b>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-4 col-md-5 col-sm-5 col-xs-5">
                                        <asp:ListBox ID="lstAvailableWidgets" runat="server" CssClass="form-control" Rows="6" Width="100%" SelectionMode="Multiple" />
                                    </div>
                                    <div class="col-md-1 col-sm-1 col-xs-1 text-center">
                                        <div class="row">
                                            <asp:LinkButton ID="btnLeft" runat="server" CssClass="btn gray_btn" OnClick="btnLeft_Click">
                                                    <i class="fa fa-arrow-left" aria-hidden="true"></i>
                                            </asp:LinkButton>
                                        </div>
                                        <div class="row">
                                            <asp:LinkButton ID="btnRight" runat="server" CssClass="btn gray_btn" OnClick="btnRight_Click">
                                                    <i class="fa fa-arrow-right" aria-hidden="true"></i>
                                            </asp:LinkButton>
                                        </div>
                                    </div>
                                    <div class="col-lg-4 col-md-5 col-sm-5 col-xs-5">
                                        <asp:ListBox ID="lstSelectedWidgets" runat="server" CssClass="form-control" Rows="6" Width="100%" SelectionMode="Multiple" />
                                    </div>
                                    <div class="col-md-1 col-sm-1 col-xs-1 text-center">
                                        <div class="row">
                                            <asp:LinkButton ID="btnUp" runat="server" CssClass="btn gray_btn" OnClick="btnUp_Click">
                                                    <i class="fa fa-arrow-up" aria-hidden="true"></i>
                                            </asp:LinkButton>
                                        </div>
                                        <div class="row">
                                            <asp:LinkButton ID="btnDown" runat="server" CssClass="btn gray_btn" OnClick="btnDown_Click">
                                                    <i class="fa fa-arrow-down" aria-hidden="true"></i>
                                            </asp:LinkButton>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <div class="row mar_top">
        <div class="col-md-12">
            <asp:LinkButton ID="btnRegister" runat="server" CssClass="btn gray_btn" OnClick="btnRegisterOnClick" OnClientClick="return RegisterOnClick();">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnRegister %>" />
            </asp:LinkButton>
            <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancelOnClick">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnCancel %>" />
            </asp:LinkButton>
        </div>
    </div>
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            ShowHideEmail();

            $('table#contentMain_rbDeliveryMethod input[type="radio"]').on('change', function () {
                ShowHideEmail();
            });

            $('#peli_PRAlertEmail').focus(function () {
                $('#contentMain_rbDeliveryMethodEmail_1').prop('checked', true);
            });

            
            $('#contentMain_rbDeliveryMethodEmail_0').click(function () {
                $("#peli_PRAlertEmail").prop("disabled", true);
            });

            $('#contentMain_rbDeliveryMethodEmail_1').click(function () {
                $("#peli_PRAlertEmail").prop("disabled", false);
                $('#peli_PRAlertEmail').focus();
            });
        });

        function ShowHideEmail() {
            var deliveryMethodVal = $('table#contentMain_rbDeliveryMethod input[type="radio"]:checked').val();
            //alert("deliveryMethodVal = " + deliveryMethodVal);
            if (deliveryMethodVal == "2" || deliveryMethodVal == "4") {
                $('#divEmail').show();

                if ($('#<%=hidPeli_PRAlertEmail.ClientID%>').val() == "" || $('#<%=hidPeli_PRAlertEmail.ClientID%>').val() == $('#<%=hidRegisteredUserEmail.ClientID%>').val()) {
                    $('#contentMain_rbDeliveryMethodEmail_0').prop('checked', true);
                }
                else {
                    $('#contentMain_rbDeliveryMethodEmail_1').prop('checked', true);
                    $("#peli_PRAlertEmail").val($('#<%=hidPeli_PRAlertEmail.ClientID%>').val());
                    $("#peli_PRAlertEmail").prop("disabled", false);
                }
            }
            else
                $('#divEmail').hide();
        }

        function RegisterOnClick() {
            $('#<%=hidPeli_PRAlertEmail.ClientID%>').val($('#peli_PRAlertEmail').val());
            return true;
        }
    </script>
</asp:Content>
