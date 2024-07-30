<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanySearchSpecie.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanySearchSpecie" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Src="UserControls/CompanySearchCriteriaControl.ascx" TagName="CompanySearchCriteriaControl" TagPrefix="uc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script>
        $(function () {
            // Replace the contents of your label with your Font Awesome icon
            $('.smallcheck label').each(function () {
                var $this = $(this);
                $this.html('<div style="display:inline-block; width:250px;">' + $this.text() + '</div>');
            });
        });
    </script>
    <style>
        .table_bbos td {
            background: transparent;
            border: none;
        }
        label div {
            display: inline-block;
            width: 250px;
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
                            <asp:AsyncPostBackTrigger ControlID="rblSearchType" EventName="SelectedIndexChanged" />
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
                    </div>
                </div>
            </div>

            <div class="col-md-9 col-sm-9 col-xs-12 medpadding_lr">
                <%--UpdatePanel2--%>
                <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                    <ContentTemplate>
                        <asp:Panel ID="pnlSpecieList" runat="server">
                            <div class="col-md-12 nopadding ind_typ mar_top">
                                <div class="col-md-4">
                                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control label_top_6" PlaceHolder='<% $Resources:Global, SearchForSpecie %>' />
                                    <cc1:AutoCompleteExtender ID="aceSpecie" runat="server"
                                        TargetControlID="txtSearch"
                                        BehaviorID="aceSpecie"
                                        ServiceMethod="GetSpecieCompletionList"
                                        ServicePath="AJAXHelper.asmx"
                                        CompletionInterval="100"
                                        MinimumPrefixLength="2"
                                        CompletionSetCount="20"
                                        CompletionListCssClass="AutoCompleteFlyout"
                                        CompletionListItemCssClass="AutoCompleteFlyoutItem"
                                        CompletionListHighlightedItemCssClass="AutoCompleteFlyoutItem"
                                        CompletionListElementID="pnlCommodityAutoComplete"
                                        OnClientPopulated="aceSpeciePopulated"
                                        OnClientItemSelected="aceSpecieSelected"
                                        DelimiterCharacters="|"
                                        EnableCaching="True"
                                        UseContextKey="True"
                                        ContextKey="7">
                                    </cc1:AutoCompleteExtender>
                                </div>
                            </div>

                            <div class="clearfix mar_bot"></div>

                            <%--Commodity Search Type--%>
                            <div class="row nomargin ind_typ">
                                <div class="col-md-12">
                                    <asp:UpdatePanel ID="UpdatePanel3" runat="server">
                                        <ContentTemplate>
                                            <div class="text-left">
                                                <asp:Label ID="lblSearchType" runat="server"><%= Resources.Global.SpecieSearchTypeText %>:</asp:Label>
                                                <br />
                                                <asp:RadioButtonList ID="rblSearchType" runat="server" RepeatColumns="3" RepeatDirection="Horizontal" AutoPostBack="True" />
                                            </div>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>
                            </div>

                            <div class="clearfix"></div>

                            <div class="panel-group" id="accordion">
                                <div class="row normargin">
                                    <div class="col-md-5">
                                        <%--Softwood--%>
                                        <div class="row nomargin">
                                            <div class="mar_top panel-default">
                                                <div class="panel-heading" role="tab" id="headingSoftwood">
                                                    <h4 class="panel-title bbos_bg commodityPanelTitle">
                                                        <asp:CheckBox value="1" ID="CHK_CLASS1" AutoPostBack="true" CssClass="commodityAllCheckbox" runat="server" />
                                                        <%= Resources.Global.Softwood %>
                                                    </h4>
                                                </div>
                                                <div class="panel-body norm_lbl">
                                                    <asp:HiddenField ID="hidSoftwood" runat="server" Value="true" />
                                                    <div class="col-md-12 gray_bg" id="Softwood">
                                                        <asp:Table ID="tblSoftwood" runat="server" Width="100%" CssClass="text-left" />
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-7">
                                        <%--Hardwood--%>
                                        <div class="row nomargin">
                                            <div class="mar_top panel-default">
                                                <div class="panel-heading" role="tab" id="headingHardwood">
                                                    <h4 class="panel-title bbos_bg commodityPanelTitle">
                                                        <asp:CheckBox value="75" ID="CHK_CLASS75" AutoPostBack="true" CssClass="commodityAllCheckbox" runat="server" />
                                                        <%= Resources.Global.Hardwood %>
                                                    </h4>
                                                </div>
                                                <div class="panel-body norm_lbl">
                                                    <asp:HiddenField ID="hidHardwood" runat="server" Value="true" />
                                                    <div class="col-md-12 gray_bg">
                                                        <div class="row">
                                                            <div class="col-md-6">
                                                                <asp:Table ID="tblHardwood1" runat="server" Width="100%" CssClass="text-left" />
                                                            </div>
                                                            <div class="col-md-6">
                                                                <asp:Table ID="tblHardwood2" runat="server" Width="100%" CssClass="text-left" />
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </asp:Panel>
                    </ContentTemplate>
                    <Triggers>
                        <%--<asp:AsyncPostBackTrigger ControlID="rblIndustryType" EventName="SelectedIndexChanged" />--%>
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

    <div id="pnlSpecieAutoComplete" style="z-index: 5000;"></div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');

        function handleFindButton(evt) {
            var evt = (evt) ? evt : ((event) ? event : null);

            if (evt.keyCode == 13) {
                if ($get("contentMain_txtSearch").value != "") {
                    //btnSubmitOnEnter = document.getElementById('btnFind');
                } else {
                    btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');
                }

                return stopRKey();
            }
        }

        document.onkeypress = handleFindButton;

        function aceSpeciePopulated(sender, e) {
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

        function aceSpecieSelected(source, eventArgs) {
            if (eventArgs.get_value() != null) {
                var aceValue = new String(eventArgs.get_value());
                $get("contentMain_txtSearch").value = new String(eventArgs.get_text());

                var checkboxID = "contentMain_CHK_CLASS" + aceValue;
                var checkboxName = "ctl00$contentMain$CHK_CLASS" + aceValue;

                var oCheckboxes = document.body.getElementsByTagName("INPUT");
                var parentTD = null;
                for (var i = 0; i < oCheckboxes.length; i++) {

                    if ((oCheckboxes[i].type == "checkbox") &&
                        (oCheckboxes[i].name == checkboxName)) {

                        oCheckboxes[i].checked = true;
                        setTimeout('__doPostBack(\'" + checkboxID + "\',\'\')', 0);
                        break;
                    }
                }
            }
        }
    </script>
</asp:Content>
