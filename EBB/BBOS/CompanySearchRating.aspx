<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanySearchRating.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanySearchRating" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Src="UserControls/CompanySearchCriteriaControl.ascx" TagName="CompanySearchCriteriaControl" TagPrefix="uc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <style>
        .form-control {
            display: inline;
            width: 95%;
        }
        .msicon.notranslate.help {
            color: white;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Panel ID="pnlSearch" DefaultButton="btnSearch" runat="server">
        <div class="row nomargin panels_box">
            <div class="col-md-3 col-sm-3 col-xs-12 nopadding">
                <%--Search Criteria--%>
                <div class="col-md-12 nopadding">
                    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                        <ContentTemplate>
                            <uc1:CompanySearchCriteriaControl ID="ucCompanySearchCriteriaControl" runat="server" />
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="rblIndustryType" EventName="SelectedIndexChanged" />
                            <%--<asp:AsyncPostBackTrigger ControlID="ddlMembershipYearSearchType" EventName="SelectedIndexChanged" />--%>
                            <%--<asp:AsyncPostBackTrigger ControlID="ddlMembershipYear" EventName="SelectedIndexChanged" />--%>
                            <asp:AsyncPostBackTrigger ControlID="ddlBBScoreSearchType" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="txtBBScore" EventName="TextChanged" />
                            <asp:AsyncPostBackTrigger ControlID="chkTMFMNotNull" EventName="CheckedChanged" />
                        </Triggers>
                    </asp:UpdatePanel>
                </div>

                <%--Buttons--%>
                <div class="col-md-12 nopadding">
                    <div class="search_crit">
                        <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn gray_btn" OnClick="btnSearch_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Search %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnClearCriteria" runat="server" CssClass="btn gray_btn" OnClick="btnClearCriteria_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ClearThisCriteria %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnClearAllCriteria" runat="server" CssClass="btn gray_btn" OnClick="btnClearAllCriteria_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ClearAllCriteria %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnSaveSearch" runat="server" CssClass="btn gray_btn" OnClick="btnSaveSearch_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, SaveSearchCriteria %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnLoadSearch" runat="server" CssClass="btn gray_btn" OnClientClick="return confirmOverrwrite('LoadSearch')" OnClick="btnLoadSearch_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, LoadSearchCriteria %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnNewSearch" runat="server" CssClass="btn gray_btn" OnClientClick="return confirmOverrwrite('NewSearch')" OnClick="btnNewSearch_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, NewSearch %>" />
                        </asp:LinkButton>
                    </div>
                </div>
            </div>
            
            <div class="col-md-9 col-sm-9 col-xs-12">
                <%--Industry Type--%>
                <asp:Panel ID="pnlIndustryType" runat="server">
                    <div class="col-md-12 nopadding ind_typ gray_bg mar_top_16">
                        <div class="row nomargin">
                            <div class="col-md-3 text-nowrap">
                                <span id="popIndustryType" runat="server" class="msicon notranslate help" tabindex="0" data-bs-toggle="tooltip" data-bs-placement="right" data-bs-html="true">help</span>
                                <span class="fontbold"><strong class=""><%= Resources.Global.IndustryType %>:</strong></span>
                            </div>
                            <div class="col-md-9">
                                <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                                    <ContentTemplate>
                                        <asp:RadioButtonList ID="rblIndustryType" runat="server" RepeatColumns="3" AutoPostBack="True"
                                            Font-Size="Smaller" OnSelectedIndexChanged="rblIndustryType_SelectedIndexChanged" />
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="rblIndustryType" EventName="SelectedIndexChanged" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </div>
                        </div>
                    </div>
                </asp:Panel>

                <%--UpdatePanel3--%>
                <div class="col-md-12 nopadding mar_top_5">
                    <asp:UpdatePanel ID="UpdatePanel3" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="false">
                        <ContentTemplate>
                            <asp:Panel ID="pnlRatingForm" runat="server">
                                <div class="row nomargin_lr">
                                    <div class="col-md-12 nopadding ind_typ gray_bg mar_top_5">
                                        <asp:Panel ID="trMembershipYear" runat="server">
                                            <div class="row nomargin_lr">
                                                <div class="col-md-12 clr_blu">
                                                    <asp:CheckBox ID="chkTMFMNotNull" runat="server" AutoPostBack="True" />
                                                    <asp:Label ID="lblTMFMNotNull" runat="server" CssClass="fontsize16"><%=Resources.Global.TradingTransportationMembers %></asp:Label>
                                                </div>
                                            </div>
                                        </asp:Panel>

                                        <asp:Panel ID="trBBScore" runat="server">
                                            <div class="row nomargin_lr">
                                                <div class="col-lg-2 col-md-2 col-sm-3 clr_blu label_top">
                                                    <asp:Panel ID="lblBBScore" runat="server">
                                                        <%= Resources.Global.BBScore %>:
                                                    </asp:Panel>
                                                </div>

                                                <div class="col-lg-10 col-md-10 col-sm-9 label_top form-inline">
                                                    <asp:DropDownList ID="ddlBBScoreSearchType" runat="server" AutoPostBack="True" CssClass="form-control" />
                                                    <asp:TextBox ID="txtBBScore" runat="server" Columns="5" MaxLength="3" AutoPostBack="True" CssClass="form-control" />

                                                    <span id="popWhatIsBBScore" runat="server" class="msicon notranslate help" tabindex="0" data-bs-toggle="tooltip" data-bs-placement="right" data-bs-html="true">help</span>
                                                </div>
                                            </div>
                                        </asp:Panel>

                                        <asp:Panel ID="trPayReportCount" runat="server">
                                            <div class="row nomargin_lr">
                                                <div class="col-lg-2 col-md-2 col-sm-3 clr_blu label_top">
                                                    <asp:Panel ID="lblPayReportCount" runat="server">
                                                        <%= Resources.Global.NumberofCurrentIndustryPayReports %>:
                                                    </asp:Panel>
                                                </div>

                                                <div class="col-lg-10 col-md-10 col-sm-9 label_top form-inline">
                                                    <asp:DropDownList ID="ddlPayReportCountSearchType" runat="server" AutoPostBack="True" CssClass="form-control" />
                                                    <asp:TextBox ID="txtPayReportCount" runat="server" Columns="5" AutoPostBack="True" CssClass="form-control" />
                                                </div>
                                            </div>
                                        </asp:Panel>


                                    </div>
                                </div>

                                <%--Trace Practices--%>
                                <asp:Panel ID="trIntegrityRating" runat="server">
                                    <div class="ind_typ bor_bot mar_top">
                                        <div class="row nomargin_lr">
                                            <div class="col-md-4">
                                                <p class="fontbold"><%= Resources.Global.IntegrityAbilityRating %>&nbsp;</p>
                                            </div>
                                            <div class="col-md-8">
                                                <p class="fontbold">
                                                    <span class="lnks">
                                                        <asp:Panel ID="pnlIntegrityLinks" runat="server" HorizontalAlign="left" CssClass="fontbold lnks"></asp:Panel>
                                                    </span>
                                                </p>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row nomargin">
                                        <div class="col-md-12 nopadding ind_typ gray_bg">
                                            <div class="col-md-12 px-2 transparent">
                                                <asp:Table ID="tblIntegrityRating" runat="server" CssClass="table table_bbos norm_lbl no_bot_marg checkboxlist-2col transparent" Width="100%"></asp:Table>
                                            </div>
                                        </div>
                                    </div>
                                </asp:Panel>

                                <%--Pay Description--%>
                                <asp:Panel ID="trPayRating" runat="server">
                                    <div class="ind_typ bor_bot mar_top">
                                        <div class="row nomargin_lr">
                                            <div class="col-md-4">
                                                <p class="fontbold"><%= Resources.Global.PayDescription %>&nbsp;</p>
                                            </div>
                                            <div class="col-md-8">
                                                <p class="fontbold">
                                                    <span class="lnks">
                                                        <asp:Panel ID="pnlPayRatingLinks" runat="server" HorizontalAlign="left" CssClass="fontbold lnks"></asp:Panel>
                                                    </span>
                                                </p>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row nomargin">
                                        <div class="col-md-12 nopadding ind_typ gray_bg">
                                            <div class="col-md-12 px-2">
                                                <asp:Table ID="tblPayRating" runat="server" CssClass="table table_bbos norm_lbl no_bot_marg checkboxlist-2col" Width="100%"></asp:Table>
                                            </div>
                                        </div>
                                    </div>
                                </asp:Panel>
                                
                                <%--Pay Indicator--%>
                                <asp:Panel ID="trPayIndicator" runat="server">
                                    <div class="ind_typ bor_bot mar_top">
                                        <div class="row nomargin_lr">
                                            <div class="col-md-4">
                                                <p class="fontbold"><%= Resources.Global.PayIndicator %>&nbsp;</p>
                                            </div>
                                            <div class="col-md-8">
                                                <p class="fontbold">
                                                    <span class="lnks">
                                                        <asp:Panel ID="pnlPayIndicatorLinks" runat="server" HorizontalAlign="left" CssClass="fontbold lnks"></asp:Panel>
                                                    </span>
                                                </p>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row nomargin">
                                        <div class="col-md-12 nopadding ind_typ gray_bg">
                                            <div class="col-md-12 px-2">
                                                <asp:Table ID="tblPayIndicator" runat="server" CssClass="table table_bbos norm_lbl no_bot_marg checkboxlist-1col" Width="100%"></asp:Table>
                                            </div>
                                        </div>
                                    </div>
                                </asp:Panel>

                                <%--Credit Worth Rating--%>
                                <asp:Panel ID="trCreditWorth" runat="server">
                                    <div class="ind_typ bor_bot mar_top">
                                        <div class="row nomargin_lr">
                                            <div class="col-md-4 form-inline">
                                                <p class="fontbold">
                                                    <%= Resources.Global.CreditWorthRating %>&nbsp;
                                                    <span id="popCreditWorth" runat="server" class="msicon notranslate help" tabindex="0" data-bs-toggle="tooltip" data-bs-placement="right" data-bs-html="true">help</span>
                                                </p>
                                            </div>
                                            <div class="col-md-8">
                                                <p class="fontbold">
                                                    <span class="lnks">
                                                        <asp:Panel ID="pnlCreditLinks" runat="server" HorizontalAlign="left" CssClass="fontbold lnks" />
                                                        <asp:Panel ID="pnlCreditLinksL" runat="server" HorizontalAlign="left" CssClass="fontbold lnks" />
                                                    </span>
                                                </p>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row nomargin">
                                        <div class="col-md-12 nopadding ind_typ gray_bg">
                                            <div class="col-md-12 px-2">
                                                <asp:Table ID="tblCreditWorthRating" runat="server" CssClass="table table_bbos norm_lbl no_bot_marg checkboxlist-4col" Width="100%" />
                                                <asp:Table ID="tblCreditWorthRatingL" runat="server" CssClass="table table_bbos norm_lbl no_bot_marg checkboxlist-4col" Width="100%" />
                                            </div>
                                        </div>
                                    </div>
                                </asp:Panel>
                            </asp:Panel>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="rblIndustryType" EventName="SelectedIndexChanged" />
                        </Triggers>
                    </asp:UpdatePanel>
                </div>
            </div>
        </div>
    </asp:Panel>

    <div class="row">
        <p>
            <% =GetSearchButtonMsg() %>
        </p>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        function ToggleInitialStateRating() {
            ToggleMustHave(document.forms[0].<%= chkTMFMNotNull.ClientID %>, 'TMFM');
        }
        btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');
    </script>
</asp:Content>
