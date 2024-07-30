<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanySearchProfile.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanySearchProfile" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Src="UserControls/CompanySearchCriteriaControl.ascx" TagName="CompanySearchCriteriaControl" TagPrefix="uc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <style>
        .table-bbos td label {
            padding-left: 0;
            left: -6px;
            position: relative;
            margin-left: 10px;
            font-size: 0.9em;
            white-space: nowrap!important;
        }
        .table-bbos td input[type="checkbox"] {
            top: 3px;
            position: relative;
        }
        #contentMain_lblVolumeText {
            padding-left: 0;
        }
    </style>
    <script>
        $(function () {
            // Replace the contents of your label with your Font Awesome icon
            $('.table-bbos td').each(function () {
                var $this = $(this);
                $this.html('<nobr>' + $this.html() + '</nobr>');
            });
        });
    </script>
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
                            <%--<asp:AsyncPostBackTrigger ControlID="txtLicenseNumber" EventName="TextChanged" />--%>
                            <asp:AsyncPostBackTrigger ControlID="txtBrands" EventName="TextChanged" />
                            <asp:AsyncPostBackTrigger ControlID="txtMiscListingInfo" EventName="TextChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cblLicenseType" EventName="SelectedIndexChanged" />
                            <%--<asp:AsyncPostBackTrigger ControlID="cblCorporateStructure" EventName="SelectedIndexChanged" />--%>
                            <asp:AsyncPostBackTrigger ControlID="rblIndustryType" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cbOrganic" EventName="CheckedChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cbFoodSafety" EventName="CheckedChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cbSalvageDistressedProduce" EventName="CheckedChanged" />
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
                                <span id="popIndustryType" runat="server" class="msicon notranslate help" tabindex="0" data-bs-toggle="tooltip" data-bs-placement="right" data-bs-html="true" data-bs-title="">help</span>
                                <span class="fontbold"><strong class=""><%= Resources.Global.IndustryType %>:</strong></span>
                            </div>
                            <div class="col-md-9">
                                <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                                    <ContentTemplate>
                                        <asp:RadioButtonList ID="rblIndustryType" runat="server" RepeatColumns="3" AutoPostBack="True" OnSelectedIndexChanged="rblIndustryType_SelectedIndexChanged"
                                            Font-Size="Smaller" />
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
                <div class="col-md-12 nopadding">
                    <asp:UpdatePanel ID="UpdatePanel3" runat="server">
                        <ContentTemplate>
                            <asp:Panel ID="trFTEmployees" runat="server">
                                <div class="ind_typ bor_bot mar_top_14">
                                    <div class="row">
                                        <div class="col-md-4">
                                            <p class="fontbold"><%= Resources.Global.FulltimeEmployees %>&nbsp;</p>
                                        </div>
                                        <div class="col-md-8">
                                            <p class="fontbold">
                                                <span class="lnks">
                                                    <asp:Panel ID="pnlFTEmployees" runat="server" HorizontalAlign="Left" CssClass="fontbold lnks"></asp:Panel>
                                                </span>
                                            </p>
                                        </div>
                                    </div>
                                </div>

                                <div class="row nomargin">
                                    <div class="col-md-12 nopadding ind_typ gray_bg">
                                        <div class="col-md-12">
                                            <asp:Table ID="tblFTEmployees" runat="server" CssClass="table table-hover table_bbos norm_lbl" Width="100%" />
                                        </div>
                                    </div>
                                </div>
                            </asp:Panel>

                            <div class="row nomargin_lr mar_top mar_bot">
                                <div class="col-md-12 nopadding ind_typ gray_bg">
                                    <asp:Panel ID="trCertifications" runat="server">
                                        <div class="row nomargin_lr">
                                            <div class="col-md-3 clr_blu">
                                                <%= Resources.Global.Certifications %>:<br />
                                            </div>
                                            <div class="col-md-9 label_top">
                                                <asp:CheckBox ID="cbOrganic" Text="<%$ Resources:Global, CertifiedOrganic %>" AutoPostBack="True" runat="server"
                                                    CssClass="nowraptd_wraplabel norm_lbl" />
                                                <br />
                                                <asp:CheckBox ID="cbFoodSafety" Text="<%$ Resources:Global, FoodSafetyCertified %>" AutoPostBack="True" runat="server"
                                                    CssClass="nowraptd_wraplabel norm_lbl" />
                                                <br />
                                                <asp:Label ID="lblCertificationsText" CssClass="annotation bbos_blue" Text="<%$ Resources:Global, CertsSelfReportedMsg %>" runat="server"></asp:Label>
                                            </div>
                                        </div>
                                    </asp:Panel>

                                    <asp:Panel ID="trLicenseType" runat="server">
                                        <div class="row nomargin_lr">
                                            <div class="col-md-3 clr_blu">
                                                <asp:Panel ID="lblLicenseType" runat="server">
                                                    <%= Resources.Global.LicenseType %>:
                                                    <br />
                                                    <asp:Panel ID="lblLTDefinitions" runat="server" CssClass="nomargin">
                                                        <span class="PopupLink annotation"><%= Resources.Global.Definitions%></span>
                                                    </asp:Panel>
                                                </asp:Panel>

                                                <asp:Panel ID="pnlLTDefinitions" Style="display: none; min-height: 300px;" CssClass="Popup" runat="server" Width="450">
                                                    <div class="popup_header">
                                                        <button type="button" class="close" data-bs-dismiss="modal" onclick="document.getElementById('contentMain_pnlLTDefinitions').style.display='none';">&times;</button>
                                                    </div>
                                                    <div class="popup_content">
                                                        <asp:Literal ID="ltWhatIsBBID" Text="<%$ Resources:Global, LicenseTypeDefinitions %>" runat="server" />
                                                    </div>
                                                </asp:Panel>

                                                <cc1:PopupControlExtender ID="pceLTDefinitions" runat="server" TargetControlID="lblLTDefinitions" PopupControlID="pnlLTDefinitions" Position="bottom" />
                                            </div>

                                            <div class="col-md-9 label_top">
                                                <asp:CheckBoxList ID="cblLicenseType" runat="server" AutoPostBack="True" RepeatColumns="3" RepeatDirection="Horizontal"
                                                    Width="100%" CssClass="checkboxlist-3col nowraptd_wraplabel norm_lbl" />
                                            </div>
                                        </div>
                                    </asp:Panel>

                                    <div class="row nomargin_lr">
                                        <div class="col-md-3 clr_blu">
                                            <asp:Panel ID="lblBrands" runat="server">
                                                <%= Resources.Global.Brands %>:
                                            </asp:Panel>
                                        </div>
                                        <div class="col-md-6 label_top">
                                            <asp:TextBox ID="txtBrands" runat="server" Columns="60" AutoPostBack="True" CssClass="form-control" />
                                        </div>
                                    </div>

                                    <div class="row nomargin_lr">
                                        <div class="col-md-3 clr_blu">
                                            <asp:Panel ID="lblMiscListingInfo" runat="server">
                                                <%= Resources.Global.MiscListingInfo %>:
                                            </asp:Panel>
                                        </div>
                                        <div class="col-md-6 label_top">
                                            <asp:TextBox ID="txtMiscListingInfo" runat="server" Columns="60" AutoPostBack="True" CssClass="form-control" />
                                        </div>
                                    </div>

                                    <div class="row nomargin_lr">
                                        <div class="col-md-12 label_top">
                                            <asp:CheckBox ID="cbSalvageDistressedProduce" Text="<%$ Resources:Global, SalvagesDistressedLoads %>" AutoPostBack="True" runat="server"
                                                CssClass="nowraptd_wraplabel norm_lbl" />
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="ind_typ bor_bot">
                                <div class="row">
                                    <div class="col-md-4 mar_top_10 bold">
                                        <%= Resources.Global.Volume %>
                                    </div>
                                    <div class="col-md-8 bold">
                                        <span class="lnks">
                                            <asp:Panel ID="pnlVolumeLinks" runat="server" HorizontalAlign="left" CssClass="fontbold lnks"></asp:Panel>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="row nomargin">
                                <div class="col-md-12 nopadding ind_typ gray_bg px-2">
                                    <div class="row">
                                        <div class="col-md-2">
                                            <asp:Label ID="lblVolumeText" CssClass="bbos_blue annotation" Text="<%$ Resources:Global, VolumeText %>" runat="server"></asp:Label>
                                        </div>
                                        <div class="col-md-10" style="position:relative; left: -25px;">
                                            <asp:Table ID="tblVolume" runat="server" CssClass="table table-hover table_bbos norm_lbl" Width="100%"></asp:Table>
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
