<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanySearchClassification.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanySearchClassification" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register Src="UserControls/CompanySearchCriteriaControl.ascx" TagName="CompanySearchCriteriaControl" TagPrefix="uc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:HiddenField ID="hidBookSection" runat="server" Value="0" />

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
                            <asp:AsyncPostBackTrigger ControlID="rblClassSearchType" EventName="SelectedIndexChanged" />
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
            <div class="col-md-9 col-sm-9 col-xs-12">
                <asp:Panel ID="pnlIndustryType" runat="server">
                    <div class="row nomargin">
                        <div class="col-md-12 nopadding ind_typ gray_bg mar_top_16">
                            <div class="row">
                                <div class="col-md-3 text-nowrap">
                                    <span id="popIndustryType" runat="server" class="msicon notranslate help" tabindex="0" data-bs-toggle="tooltip" data-bs-placement="right" data-bs-html="true" data-bs-title="">help</span>
                                    <span class="fontbold"><strong class=""><%= Resources.Global.IndustryType %>:</strong></span>
                                </div>
                                <div class="col-md-9">
                                    <asp:UpdatePanel ID="UpdatePanel3" runat="server">
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
                    </div>
                </asp:Panel>

                <%--Classifications--%>
                <div class="row nomargin_lr ind_typ mar_top_14">
                    <div class="col-md-12">
                        <asp:UpdatePanel ID="UpdatePanel5" runat="server">
                            <ContentTemplate>
                                <div style="text-left">
                                    <asp:Label ID="lblClassSearchType" runat="server"><%= Resources.Global.ClassificationSearchTypeText %>:</asp:Label>
                                    <br />
                                    <asp:RadioButtonList ID="rblClassSearchType" runat="server" RepeatColumns="3" RepeatDirection="Horizontal" 
                                        AutoPostBack="True" RepeatLayout="Flow" />
                                </div>
                            </ContentTemplate>
                            <Triggers>
                                <%--<asp:AsyncPostBackTrigger ControlID="pnlProduceClass" EventName="Load" />--%> 
                            </Triggers>
                        </asp:UpdatePanel>
                    </div>
                </div>

                <div class="col-md-12 nopadding_lr">
                    <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                        <ContentTemplate>
                            <div class="panel-group" id="accordion" runat="server">
                                <asp:Panel ID="pnlProduceClass" runat="server" />
                                <asp:Panel ID="pnlTransportationClass" runat="server" />
                                <asp:Panel ID="pnlSupplyClass" runat="server" />
                                <asp:Panel ID="pnlLumberClass" runat="server" />
                            </div>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="rblIndustryType" EventName="SelectedIndexChanged" />
                        </Triggers>
                    </asp:UpdatePanel>
                </div>

                <%--Number of Stores--%>
                <div class="col-md-12 nopadding">
                    <asp:UpdatePanel ID="UpdatePanel4" runat="server">
                        <ContentTemplate>
                            <asp:Panel ID="pnlNumberOfStores" runat="server">
                                <div class="row nomargin">
                                    <div class="panel-heading" role="tab">
                                        <h4 class="panel-title bbos_bg commodityPanelTitle">
                                            <asp:Label ID="lblRetailStores" runat="server" Enabled="false"><%= ((string)Resources.Global.NumberOfRetailStores).Replace("<br />"," ") %></asp:Label>
                                        </h4>
                                    </div>
                                    <div class="panel-body norm_lbl">
                                        <div class="col-md-12 gray_bg">
                                            <asp:CheckBoxList ID="cblNumOfRetail" runat="server" AutoPostBack="True" RepeatColumns="4" RepeatDirection="Horizontal" Enabled="false"
                                                Width="100%"
                                                RepeatLayout="Table"
                                                CssClass="checkboxlist-4col nowraptd_wraplabel norm_lbl" />
                                        </div>
                                    </div>
                                </div>

                                <div class="row nomargin_lr mar_top">
                                    <div class="panel-heading" role="tab">
                                        <h4 class="panel-title bbos_bg commodityPanelTitle">
                                            <asp:Label ID="lblRestaurantStores" runat="server" Enabled="false"><%= ((string)Resources.Global.NumberOfRestaurantStores).Replace("<br />"," ") %></asp:Label>
                                        </h4>
                                    </div>
                                    <div class="panel-body norm_lbl">
                                        <div class="col-md-12 gray_bg">
                                        <asp:CheckBoxList ID="cblNumOfRestaurants" runat="server" AutoPostBack="True" RepeatColumns="4" RepeatDirection="Horizontal" Enabled="false"
                                            Width="100%"
                                            CssClass="checkboxlist-4col nowraptd_wraplabel norm_lbl" />
                                        </div>
                                    </div>
                                </div>
                            </asp:Panel>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>

                <div class="row">
                    <p>
                        <% =GetSearchButtonMsg() %>
                    </p>
                </div>

            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlGrowerIncludeLSS" Style="display: none;" CssClass="Popup" Width="300px" Height="100px" runat="server">
        <div style="text-align: left;">Would you also like to include Local Source records in your search results?</div>
        <div style="text-align: center; position: absolute; bottom: 0; padding-top: 10px; padding-bottom: 5px; margin-right: 25px; width: 100%;">
            <a href="javascript:includeLSS();" class="SmallButton" style="width: 100px"><%=Resources.Global.Yes %></a>
            <asp:LinkButton CssClass="SmallButton gray_btn" ID="btnCancel" Text="<%$ Resources:Global, No %>" Width="100px" runat="server" />
        </div>
    </asp:Panel>

    <cc1:ModalPopupExtender
        ID="mpeGrowerIncludePopup"
        BehaviorID="mpeGrowerIncludePopup"
        TargetControlID="btnGrowerInclude"
        PopupControlID="pnlGrowerIncludeLSS"
        CancelControlID="btnCancel"
        DropShadow="true"
        BackgroundCssClass="modalBackground"
        runat="server" />

    <div style="display: none;">
        <asp:Button ID="btnGrowerInclude" CssClass="btn gray_btn" runat="server" />
    </div>

    <asp:HiddenField ID="CheckGrowerIncludeLSS" runat="server" />
    <asp:HiddenField ID="GrowerIncludeLSS" runat="server" />
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');

        function checkForLSS() {
            var cbControl = document.getElementById("contentMain_CHK_CLASS360");

            if (document.getElementById("<% =CheckGrowerIncludeLSS.ClientID %>").value == "Y") {

                if ((cbControl.checked) &&
                    (document.getElementById("<% =GrowerIncludeLSS.ClientID %>").value == "")) {

                    $find("mpeGrowerIncludePopup").show();
                }
            }
        }

        function includeLSS() {
            document.getElementById("<% =GrowerIncludeLSS.ClientID %>").value = "Y";
            __doPostBack("", "")
        }

        function Toggle_Hid(szSpanID, oHid) {
            var oSpan = document.getElementById(szSpanID);
            var oImg = document.getElementById('img' + szSpanID);

            if (oSpan == null)
                return;

            //toggle state
            if (oHid.value == null || oHid.value == "" || oHid.value == "false")
                oHid.value = "true";
            else
                oHid.value = "false"

            Set_Hid_Display(szSpanID, oHid);
        }

        function Set_Hid_Display(szSpanID, oHid) {
            var oSpan = document.getElementById(szSpanID);
            var oImg = document.getElementById('img' + szSpanID);

            if (oSpan == null)
                return;

            if (oHid.value == "false") {
                oSpan.style.display = "none";

                $("#img" + szSpanID).removeClass("glyphicon-minus");
                $("#img" + szSpanID).addClass("glyphicon-plus");

                oImg.src = imgPlus;
            }
            else {
                oSpan.style.display = "";
                $("#img" + szSpanID).addClass("glyphicon-minus");
                $("#img" + szSpanID).removeClass("glyphicon-plus");

                oImg.src = imgMinus;
            }
        }

        function initPageDisplay() {
            var $currentElem;
            $('#contentMain_pnlProduceClass').find('input:hidden').each(function () {
                $currentElem = $(this)[0];
                var szPnl = $currentElem.id.substring(15); //remove prefix
                Set_Hid_Display(szPnl, $currentElem);
            });
        }

        function disableParent(child) {
            if (!child.checked) {
                document.getElementById('contentMain_' + child.attributes['parentid'].value).checked = false;
            }
        }

        $(function () {
            $("#contentMain_rblIndustryType input").click(clickIndustryType);
        });
        function clickIndustryType(t) {
            var $this = (!t) ? $("#contentMain_rblIndustryType input:checked") : $(this);
            setTimeout(function () {
                if ($this.val() == "S") {
                    if (!$("#IndustrySupplierorServiceProvider .msicon").length && !$("#ProveedordeServiciooProveedorIndustrial .msicon").length) {
                        setTimeout(clickIndustryType, 50);
                        return false;
                    }
                    $("#IndustrySupplierorServiceProvider .msicon").remove();
                    $("#ProveedordeServiciooProveedorIndustrial .msicon").remove();
                }
                else if ($this.val() == "P") {
                    if (!$("#ProduceBuyer .msicon").length) {
                        setTimeout(clickIndustryType, 50);
                        return false;
                    }
                    setTooltips();
                }
                else {
                    if (!$("#Transportation .msicon").length) {
                        setTimeout(clickIndustryType, 50);
                        return false;
                    }
                    setTooltips();
                }
                $("#contentMain_rblIndustryType input").unbind("click");
                $("#contentMain_rblIndustryType input").click(clickIndustryType);
            }, 1);
        }
        clickIndustryType();
        Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(initPageDisplay);
    </script>
</asp:Content>
