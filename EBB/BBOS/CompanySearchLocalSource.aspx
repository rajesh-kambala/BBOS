<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanySearchLocalSource.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanySearchLocalSource" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Src="UserControls\CompanySearchCriteriaControl.ascx" TagName="CompanySearchCriteriaControl" TagPrefix="uc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentHead" runat="server">
    <style>
        a.clr_blc img {
            width: 14px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Panel ID="pnlSearch" DefaultButton="btnSearch" runat="server">

        <div class="row nomargin panels_box">
            <div class="col-md-3 col-sm-4 col-xs-12 nopadding">
                <%--Search Criteria--%>
                <div class="col-md-12 nopadding">
                    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                        <ContentTemplate>
                            <uc1:CompanySearchCriteriaControl ID="ucCompanySearchCriteriaControl" runat="server" />
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="ddlIncludeLocalSource" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cbCertifiedOrganic" EventName="CheckedChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cblAlsoOperates" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="rblIndustryType" EventName="SelectedIndexChanged" />
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

            <%--Industry Type--%>
            <div class="col-md-9 col-sm-8 col-xs-12">
                <asp:Panel ID="pnlIndustryType" runat="server">
                    <div class="col-md-12 nopadding ind_typ gray_bg mar_top_16">
                        <div class="row nomargin">
                            <div class="col-md-3 text-nowrap">
                                <a id="popIndustryType" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                                    <img src="images/info_sm.png" />
                                </a>
                                <span class="fontbold"><strong class=""><%= Resources.Global.IndustryType %>:</strong></span>
                            </div>
                            <div class="col-md-9">
                                <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                                    <ContentTemplate>
                                        <asp:RadioButtonList ID="rblIndustryType" runat="server" RepeatColumns="3" AutoPostBack="True"
                                            Font-Size="Smaller"/>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="rblIndustryType" EventName="SelectedIndexChanged" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </div>
                        </div>
                    </div>
                </asp:Panel>

                <div class="col-md-12 nopadding">
                    <div class="row clr_blu mar_bot mar_top_5">
                        <div class="col-md-12">
                            <%= Resources.Global.MeisterMediaSearchPageMsg %>
                        </div>
                    </div>

                    <asp:UpdatePanel ID="UpdatePanel3" runat="server">
                        <ContentTemplate>
                            <div class="row nomargin_lr">
                                <div class="col-md-12 nopadding ind_typ gray_bg">
                                    <div class="row nomargin_lr">
                                        <div class="col-md-3 col-sm-4 clr_blu">
                                            <%=Resources.Global.LocalSourceData2 %>:
                                        </div>
                                        <div class="col-md-4 col-sm-6">
                                            <asp:DropDownList ID="ddlIncludeLocalSource" runat="server" AutoPostBack="True" CssClass="form-control" />
                                        </div>
                                        <div class="col-md-1 col-sm-1 text-left">
                                            <a id="popLocalSourceData" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                                                <img src="images/info_sm.png" />
                                            </a>
                                        </div>
                                    </div>

                                    <div class="row nomargin_lr">
                                        <div class="col-md-3 col-sm-4 clr_blu">
                                            <%= Resources.Global.GrowsOrganic %>:
                                        </div>
                                        <div class="col-md-1 col-sm-1 text-left">
                                            <asp:CheckBox ID="cbCertifiedOrganic" runat="server" AutoPostBack="True" />
                                        </div>
                                    </div>

                                    <div class="row nomargin_lr">
                                        <div class="col-md-3 col-sm-4 clr_blu">
                                            <%= Resources.Global.AlsoOperates %>:
                                        </div>
                                        <div class="col-md-9 col-sm-8 text-left">
                                            <asp:CheckBoxList ID="cblAlsoOperates" runat="server" AutoPostBack="True" RepeatColumns="1" RepeatDirection="Horizontal" RepeatLayout="Flow"
                                                CssClass="checkboxlist-1col nowraptd_wraplabel norm_lbl nopadding_lr" />
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="ind_typ bor_bot mar_top">
                                <div class="row">
                                    <div class="col-md-4">
                                        <p class="fontbold"><%= Resources.Global.TotalAcres %>&nbsp;</p>
                                    </div>
                                    <div class="col-md-8">
                                        <p class="fontbold">
                                            <span class="lnks">
                                                <asp:Panel ID="pnlTotalAcresLinks" runat="server" HorizontalAlign="right" CssClass="fontbold lnks"></asp:Panel>
                                            </span>
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <div class="row nomargin">
                                <div class="col-md-12 nopadding ind_typ gray_bg">
                                    <div class="row nomargin_lr">
                                        <div class="col-md-12">
                                            <asp:Table ID="tblTotalAcres" runat="server" CssClass="table table-striped table-hover table_bbos norm_lbl"></asp:Table>
                                        </div>
                                    </div>
                                </div>
                            </div>
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
        btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');
    </script>
</asp:Content>
