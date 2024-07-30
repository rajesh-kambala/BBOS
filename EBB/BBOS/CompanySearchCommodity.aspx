<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanySearchCommodity.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanySearchCommodity" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Src="UserControls/CompanySearchCriteriaControl.ascx" TagName="CompanySearchCriteriaControl" TagPrefix="uc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
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
                            <asp:AsyncPostBackTrigger ControlID="rblCommoditySearchType" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="rblGrowingMethod" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="rblCountryOfOrigin" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="rblSizeGroup" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="rblStyle" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="rblTreatment" EventName="SelectedIndexChanged" />
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

            <div class="col-md-9 col-sm-9 col-xs-12 medpadding_lr">
                <asp:Panel ID="pnlIndustryType" runat="server">
                    <%--Industry Type--%>
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

                <%--UpdatePanel2--%>
                <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                    <ContentTemplate>
                        <asp:Panel ID="pnlExpandedContents" runat="server">
                            <%--Growing Method--%>
                            <div class="col-md-12 nopadding ind_typ gray_bg mar_top">
                                <div class="row">
                                    <div class="col-md-3">
                                        <span class="fontbold"><strong class=""><%= Resources.Global.GrowingMethod %>:</strong></span>
                                    </div>
                                    <div class="col-md-9">
                                        <span class="bbos_blue"><%= Resources.Global.GrowingMethodAttributeText %></span>

                                        <asp:RadioButtonList ID="rblGrowingMethod" runat="server" CssClass="table_bbos norm_lbl" RepeatDirection="Horizontal" AutoPostBack="true" RepeatLayout="Table"
                                            Font-Size="Smaller" />
                                    </div>
                                </div>
                            </div>

                            <%--Attributes--%>
                            <div class="col-md-12 nopadding ind_typ gray_bg mar_top">
                                <div class="col-md-12">
                                    <span class="fontbold"><strong class=""><%= Resources.Global.Attributes %>:</strong></span>
                                </div>
                                <div class="col-md-12 px-2">
                                    <div id="atView" class="btn gray_btn" onclick="javascript:ToggleAttr(true);">
                                        <i class="fa fa-caret-right" aria-hidden="true" runat="server" />&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ShowAttributes %>" />
                                    </div>

                                    <div id="atHide" class="btn gray_btn" style="display: none;" onclick="javascript:ToggleAttr(false);">
                                        <i class="fa fa-caret-right" aria-hidden="true" runat="server" />&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, HideAttributes %>" />
                                    </div>

                                    <div id="attributes" style="display: none;" class="mar_top">
                                        <asp:RadioButton ID="rbAttributeAll" runat="server" OnCheckedChanged="rblAttributeAll_OnChange" AutoPostBack="true" Text="<%$Resources:Global, All%>" />

                                        <div class="table table-striped table-hover table_bbos" style="width: 100%">
                                            <div class="row">
                                                <div class="col-md-2 bbos_blue bold">
                                                    <asp:Literal ID="lblCountryOfOrigin" runat="server" />:
                                                </div>
                                                <div class="col-md-10">
                                                    <asp:RadioButtonList ID="rblCountryOfOrigin" runat="server" CssClass="space smallcheck fixWidth_33 nowraptd_wraplabel vertical-align-top transparent" RepeatColumns="3" RepeatDirection="Horizontal" AutoPostBack="True" OnSelectedIndexChanged="rblCountryOfOrigin_SelectedIndexChanged"
                                                        RepeatLayout="Table" Width="100%" />
                                                </div>
                                            </div>

                                            <div class="row mar_top">
                                                <div class="col-md-2 bbos_blue bold">
                                                    <asp:Literal ID="lblSizeGroup" runat="server" />:
                                                </div>
                                                <div class="col-md-10">
                                                    <asp:RadioButtonList ID="rblSizeGroup" runat="server" CssClass="space smallcheck fixWidth_33 nowraptd_wraplabel vertical-align-top transparent" RepeatColumns="3" RepeatDirection="Horizontal" AutoPostBack="True" OnSelectedIndexChanged="rblSizeGroup_SelectedIndexChanged"
                                                        RepeatLayout="Table" Width="100%" />
                                                </div>
                                            </div>

                                            <div class="row mar_top">
                                                <div class="col-md-2 bbos_blue bold">
                                                    <asp:Literal ID="lblStyle" runat="server" />:
                                                </div>
                                                <div class="col-md-10">
                                                    <asp:RadioButtonList ID="rblStyle" runat="server" CssClass="space smallcheck fixWidth_33 nowraptd_wraplabel vertical-align-top transparent" RepeatColumns="3" RepeatDirection="Horizontal" AutoPostBack="True" OnSelectedIndexChanged="rblStyle_SelectedIndexChanged"
                                                        RepeatLayout="Table" Width="100%" />
                                                </div>
                                            </div>

                                            <div class="row mar_top">
                                                <div class="col-md-2 bbos_blue bold">
                                                    <asp:Literal ID="lblTreatment" runat="server" />:
                                                </div>
                                                <div class="col-md-10">
                                                    <asp:RadioButtonList ID="rblTreatment" runat="server" CssClass="space smallcheck fixWidth_33 nowraptd_wraplabel vertical-align-top transparent" RepeatColumns="4" RepeatDirection="Horizontal" AutoPostBack="True" OnSelectedIndexChanged="rblTreatment_SelectedIndexChanged"
                                                        RepeatLayout="Table" Width="100%" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </asp:Panel>

                        <asp:Panel ID="pnlCommodityList" runat="server">
                            <div class="col-md-12 nopadding ind_typ mar_top px-2 ">
                                <div class="col-md-4">
                                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control label_top_6" PlaceHolder='<% $Resources:Global, SearchForCommodity %>' />
                                    <cc1:AutoCompleteExtender ID="aceCommodity" runat="server"
                                        TargetControlID="txtSearch"
                                        BehaviorID="aceCommodity"
                                        ServiceMethod="GetCommodityCompletionList"
                                        ServicePath="AJAXHelper.asmx"
                                        CompletionInterval="100"
                                        MinimumPrefixLength="2"
                                        CompletionSetCount="20"
                                        CompletionListCssClass="AutoCompleteFlyout"
                                        CompletionListItemCssClass="AutoCompleteFlyoutItem"
                                        CompletionListHighlightedItemCssClass="AutoCompleteFlyoutItem"
                                        CompletionListElementID="pnlCommodityAutoComplete"
                                        OnClientPopulated="aceCommodityPopulated"
                                        OnClientItemSelected="aceCommoditySelected"
                                        DelimiterCharacters="|"
                                        EnableCaching="True"
                                        UseContextKey="True">
                                    </cc1:AutoCompleteExtender>
                                </div>
                                <%-- <div class="col-md-6">
                                    <button onclick="findString($get('<%=txtSearch.ClientID %>').value);" type="button" class="btn gray_btn" style="width:165px;" id="btnFind">
                                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, SearchCommodity%>" />
                                    </button>
                                    &nbsp;
                                    <asp:HyperLink ID="hlPageView" CssClass="btn gray_btn" runat="server">
                                        <i class="fa fa-caret-right" aria-hidden="true" runat="server" />&nbsp;<asp:Literal ID="hlPageViewTitle" runat="server" />
                                    </asp:HyperLink>
                                </div>--%>
                            </div>

                            <div class="clearfix mar_bot"></div>

                            <%--Commodity Search Type--%>
                            <div class="row nomargin ind_typ">
                                <div class="col-md-12">
                                    <asp:UpdatePanel ID="UpdatePanel4" runat="server">
                                        <ContentTemplate>
                                            <div class="text-left">
                                                <asp:Label runat="server"><%= Resources.Global.CommoditySearchTypeText %>:</asp:Label>
                                                <br />
                                                <asp:RadioButtonList ID="rblCommoditySearchType" runat="server" RepeatColumns="3" RepeatDirection="Horizontal" AutoPostBack="True" />
                                            </div>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>
                            </div>

                            <div class="clearfix"></div>

                            <div class="panel-group" id="accordion">
                                <%--Fruits--%>
                                <div class="row nomargin">
                                    <div class="mar_top panel-default">
                                        <div class="panel-heading" role="tab" id="headingFruits">
                                            <h4 class="panel-title bbos_bg commodityPanelTitle">
                                                <asp:CheckBox value="37" ID="cbFruit" AutoPostBack="true" CssClass="commodityAllCheckbox" onclick="toggleTable('contentMain_cbFruit', 'contentMain_tblFruit');e.stopPropagation();" runat="server" />
                                                <%= Resources.Global.Fruit %>
                                                <i id="imgFruit" class="more-less glyphicon glyphicon-minus" onclick="Toggle_Hid('Fruit', document.getElementById('<%=hidFruit.ClientID%>'));"></i>
                                            </h4>
                                        </div>
                                        <div class="panel-body norm_lbl">
                                            <asp:HiddenField ID="hidFruit" runat="server" Value="true" />
                                            <div class="col-md-12 gray_bg" id="Fruit">
                                                <asp:CheckBoxList ID="tblFruit" RepeatDirection="Vertical" AutoPostBack="true" RepeatColumns="3" runat="server"
                                                    CssClass="checkboxlist-3col nowraptd_wraplabel"
                                                    RepeatLayout="Table" Width="100%" />
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="clearfix"></div>

                                <%--Vegetable--%>
                                <div class="row nomargin">
                                    <div class="mar_top panel-default">
                                        <div class="panel-heading" role="tab" id="headingVegetables">
                                            <h4 class="panel-title bbos_bg commodityPanelTitle">
                                                <asp:CheckBox value="291" ID="cbVegetable" AutoPostBack="true" CssClass="commodityAllCheckbox" onclick="toggleTable('contentMain_cbVegetable', 'contentMain_tblVegetable');" runat="server" /><%--Set onclick in code-behind --%>
                                                <%= Resources.Global.Vegetable %>
                                                <i id="imgVegetable" class="more-less glyphicon glyphicon-minus" onclick="Toggle_Hid('Vegetable', document.getElementById('<%=hidVegetable.ClientID%>'));"></i>
                                            </h4>
                                        </div>
                                        <div class="panel-body norm_lbl">
                                            <asp:HiddenField ID="hidVegetable" runat="server" Value="true" />
                                            <div class="col-md-12 gray_bg" id="Vegetable">
                                                <asp:CheckBoxList ID="tblVegetable" Width="100%" RepeatDirection="Vertical" AutoPostBack="true" RepeatColumns="3" runat="server"
                                                    CssClass="checkboxlist-3col nowraptd_wraplabel"
                                                    RepeatLayout="Table" />
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="clearfix"></div>

                                <%--Herbs--%>
                                <div class="row nomargin">
                                    <div class="mar_top panel-default">
                                        <div class="panel-heading" role="tab" id="headingHerbs">
                                            <h4 class="panel-title bbos_bg commodityPanelTitle">
                                                <asp:CheckBox value="248" ID="cbHerb" AutoPostBack="true" runat="server" onclick="toggleTable('contentMain_cbHerb', 'contentMain_tblHerb');" />
                                                <%= Resources.Global.Herb %>
                                                <i id="imgHerb" class="more-less glyphicon glyphicon-minus" onclick="Toggle_Hid('Herb', document.getElementById('<%=hidHerb.ClientID%>'));"></i>
                                            </h4>
                                        </div>
                                        <div class="panel-body norm_lbl">
                                            <asp:HiddenField ID="hidHerb" runat="server" Value="true" />
                                            <div class="col-md-12 col-sm-12 col-xs-12 gray_bg" id="Herb">
                                                <asp:CheckBoxList ID="tblHerb" Width="100%" RepeatDirection="Vertical" AutoPostBack="true" RepeatColumns="3" runat="server"
                                                    CssClass="checkboxlist-3col nowraptd_wraplabel"
                                                    RepeatLayout="Table" />
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="clearfix"></div>

                                <%--Food--%>
                                <div class="row nomargin">
                                    <div class="mar_top panel-default">
                                        <div class="panel-heading" role="tab" id="headingFood">
                                            <h4 class="panel-title bbos_bg commodityPanelTitle">
                                                <asp:CheckBox value="248" ID="cbFood" AutoPostBack="true" runat="server" onclick="toggleTable('contentMain_cbFood', 'contentMain_tblFood');" />
                                                <%= Resources.Global.Food %>
                                                <i id="imgFood" class="more-less glyphicon glyphicon-minus" onclick="Toggle_Hid('Food', document.getElementById('<%=hidFood.ClientID%>'));"></i>
                                            </h4>
                                        </div>

                                        <div class="panel-body norm_lbl">
                                            <div class="col-md-12 col-sm-12 col-xs-12 gray_bg" id="Food">
                                                <asp:HiddenField ID="hidFood" runat="server" Value="true" />
                                                <asp:CheckBoxList ID="tblFood" Width="100%" RepeatDirection="Vertical" AutoPostBack="true" RepeatColumns="3" runat="server"
                                                    CssClass="checkboxlist-3col nowraptd_wraplabel"
                                                    RepeatLayout="Table" />
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="clearfix"></div>

                                <%--Nut--%>
                                <div class="row nomargin">
                                    <div class="mar_top panel-default">
                                        <div class="panel-heading" role="tab" id="headingNut">
                                            <h4 class="panel-title bbos_bg commodityPanelTitle">
                                                <asp:CheckBox value="248" ID="cbNut" AutoPostBack="true" runat="server" onclick="toggleTable('contentMain_cbNut', 'contentMain_tblNut');" />
                                                <%= Resources.Global.Nut %>
                                                <i id="imgNut" class="more-less glyphicon glyphicon-minus" onclick="Toggle_Hid('Nut', document.getElementById('<%=hidNut.ClientID%>'));"></i>
                                            </h4>
                                        </div>
                                        <div class="panel-body norm_lbl">
                                            <div class="col-md-12 col-sm-12 col-xs-12 gray_bg" id="Nut">
                                                <asp:HiddenField ID="hidNut" runat="server" Value="true" />
                                                <asp:CheckBoxList ID="tblNut" RepeatDirection="Vertical" AutoPostBack="true" RepeatColumns="3" runat="server"
                                                    CssClass="checkboxlist-3col nowraptd_wraplabel"
                                                    RepeatLayout="Table" Width="100%" />
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="clearfix"></div>

                                <%--Flower--%>
                                <div class="row nomargin">
                                    <div class="mar_top panel-default">
                                        <div class="panel-heading" role="tab" id="headingFlower">
                                            <h4 class="panel-title bbos_bg commodityPanelTitle">
                                                <asp:CheckBox value="248" ID="cbFlower" AutoPostBack="true" runat="server" onclick="toggleTable('contentMain_cbFlower', 'contentMain_tblFlower');" />
                                                <%= Resources.Global.FlowerPlantTrees %>
                                                <i id="imgFlower" class="more-less glyphicon glyphicon-minus" onclick="Toggle_Hid('Flower', document.getElementById('<%=hidFlower.ClientID%>'));"></i>
                                            </h4>
                                        </div>
                                        <div class="panel-body norm_lbl">
                                            <asp:HiddenField ID="hidFlower" runat="server" Value="true" />
                                            <div class="col-md-12 col-sm-12 col-xs-12 gray_bg" id="Flower">
                                                <asp:CheckBoxList ID="tblFlower" RepeatDirection="Vertical" AutoPostBack="true" RepeatColumns="3" runat="server"
                                                    CssClass="checkboxlist-3col nowraptd_wraplabel" 
                                                    RepeatLayout="Table" Width="100%" />
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="clearfix"></div>

                                <%--Spice--%>
                                <div class="row nomargin">
                                    <div class="mar_top panel-default">
                                        <div class="panel-heading" role="tab" id="headingSpice">
                                            <h4 class="panel-title bbos_bg commodityPanelTitle">
                                                <asp:CheckBox value="291" ID="cbSpice" AutoPostBack="true" CssClass="commodityAllCheckbox" onclick="toggleTable('contentMain_cbSpice', 'contentMain_tblSpice');" runat="server" /><%--Set onclick in code-behind --%>
                                                <%= Resources.Global.Spice %>
                                                <i id="imgSpice" class="more-less glyphicon glyphicon-minus" onclick="Toggle_Hid('Spice', document.getElementById('<%=hidSpice.ClientID%>'));"></i>
                                            </h4>
                                        </div>

                                        <div class="panel-body norm_lbl">
                                            <asp:HiddenField ID="hidSpice" runat="server" Value="true" />
                                            <div class="col-md-12 col-sm-12 col-xs-12 gray_bg" id="Spice">
                                                <asp:CheckBoxList ID="tblSpice" RepeatDirection="Vertical" AutoPostBack="true" RepeatColumns="3" runat="server"
                                                    CssClass="checkboxlist-3col nowraptd_wraplabel" Width="100%" RepeatLayout="Table" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                        </asp:Panel>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="rblIndustryType" EventName="SelectedIndexChanged" />
                    </Triggers>
                </asp:UpdatePanel>
            </div>
        </div>
    </asp:Panel>

    <div class="row">
        <p>
            <% =GetSearchButtonMsg() %>
        </p>
    </div>

    <div id="pnlCommodityAutoComplete" style="z-index: 5000;"></div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript" src="en-us/javascript/toggleFunctions.min.js"></script>

    <script type="text/javascript">
        function ToggleAttr(display) {
            if (display) {
                document.getElementById("attributes").style.display = "";
                document.getElementById("atHide").style.display = "";
                document.getElementById("atView").style.display = "none";
            } else {
                document.getElementById("attributes").style.display = "none";
                document.getElementById("atHide").style.display = "none";
                document.getElementById("atView").style.display = "";
            }
        }

        function checkForToggle() {
            if (IsItemSelected("ctl00$contentMain$rblCountryOfOrigin") ||
                IsItemSelected("ctl00$contentMain$rblSizeGroup") ||
                IsItemSelected("ctl00$contentMain$rblStyle") ||
                IsItemSelected("ctl00$contentMain$rblTreatment")) {
                ToggleAttr(true)
            }
        }

        function IsItemSelected(szName) {
            oListControl = document.getElementsByName(szName);
            for (var i = 0; i < oListControl.length; i++) {
                if (oListControl[i].checked) {
                    return true;
                }
            }

            return false;
        }



    </script>

    <script type="text/javascript">
        function handleFindButton(evt) {
            var evt = (evt) ? evt : ((event) ? event : null);

            if (evt.keyCode == 13) {
                if ($get("<%=txtSearch.ClientID%>").value != "") {
                    btnSubmitOnEnter = document.getElementById('btnFind');
                } else {
                    btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');
                }

                return stopRKey();
            }
        }

        document.onkeypress = handleFindButton;

        function aceCommodityPopulated(sender, e) {
            var target = sender.get_completionList();
            target.className = "AutoCompleteFlyout";

            var children = target.childNodes;
            for (var i = 0; i < children.length; i++) {
                var child = children[i];
                if (i % 2 == 0) {
                    child.className = "AutoCompleteFlyoutItem";
                } else {
                    child.className = "AutoCompleteFlyoutShadeItem";
                }
            }
        }

        function aceCommoditySelected(source, eventArgs) {
            if (eventArgs.get_value() != null) {
                var aceValue = new String(eventArgs.get_value());
                $get("<%=txtSearch.ClientID%>").value = new String(eventArgs.get_text());

                var checkboxID = "contentMain_CHK_COMM" + aceValue;
                var checkboxName = "ctl00$contentMain$CHK_COMM" + aceValue;

                var oCheckboxes = document.body.getElementsByTagName("INPUT");
                var parentTD = null;
                for (var i = 0; i < oCheckboxes.length; i++) {

                    if ((oCheckboxes[i].type == "checkbox") &&
                        (oCheckboxes[i].value == aceValue)) {

                        oCheckboxes[i].checked = true;
                        setTimeout('__doPostBack(\'" + checkboxID + "\',\'\')', 0);
                        break;
                    }
                }
            }
        }

        function initPageDisplay() {
            var c = document.getElementById('<%=hidFruit.ClientID%>');
            if (c != null){
                Set_Hid_Display('Fruit', c);
                toggleTable('<%=cbFruit.ClientID%>', '<%=tblFruit.ClientID%>');
            }

            c = document.getElementById('<%=hidVegetable.ClientID%>');
            if (c != null) {
                Set_Hid_Display('Vegetable',c);
                toggleTable('<%=cbVegetable.ClientID%>', '<%=tblVegetable.ClientID%>');
            }

            c = document.getElementById('<%=hidHerb.ClientID%>');
            if (c != null) {
                Set_Hid_Display('Herb', c);
                toggleTable('<%=cbHerb.ClientID%>', '<%=tblHerb.ClientID%>');
            }

            c = document.getElementById('<%=hidFood.ClientID%>');
            if (c != null) {
                Set_Hid_Display('Food', c);
                toggleTable('<%=cbFood.ClientID%>', '<%=tblFood.ClientID%>');
            }

            c = document.getElementById('<%=hidNut.ClientID%>');
            if (c != null) {
                Set_Hid_Display('Nut', c);
                toggleTable('<%=cbNut.ClientID%>', '<%=tblNut.ClientID%>');
            }

            c = document.getElementById('<%=hidFlower.ClientID%>');
            if (c != null) {
                Set_Hid_Display('Flower', c);
                toggleTable('<%=cbFlower.ClientID%>', '<%=tblFlower.ClientID%>');
            }

            c = document.getElementById('<%=hidSpice.ClientID%>');
            if (c != null) {
                Set_Hid_Display('Spice', c);
                toggleTable('<%=cbSpice.ClientID%>', '<%=tblSpice.ClientID%>');
            }
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

        function toggleTable(checkboxID, tableID) {
            var eCheckbox = document.getElementById(checkboxID);
            var eTable = document.getElementById(tableID);

            if (eCheckbox == null || eTable == null)
                return;

            var rows = eTable.rows;

            for (i = 0; i < rows.length; i++) {
                var row = rows[i];

                var cells = row.cells;
                for (j = 0; j < cells.length; j++) {

                    var controls = cells[j].childNodes;
                    for (k = 0; k < controls.length; k++) {
                        var checkbox = controls[k];
                        checkbox.disabled = eCheckbox.checked;
                        if (eCheckbox.checked) {
                            checkbox.checked = false;
                        }
                    }
                }
            }
        }

        Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(initPageDisplay);
        Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(checkForToggle);
    </script>
</asp:Content>
