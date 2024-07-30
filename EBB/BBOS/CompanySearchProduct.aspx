<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanySearchProduct.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanySearchProduct" %>

<%@ Register Src="UserControls/CompanySearchCriteriaControl.ascx" TagName="CompanySearchCriteriaControl" TagPrefix="uc1" %>

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

            <div class="col-md-9 col-sm-8 col-xs-12 mar_top_15">
                <%--Product Search Type--%>
                <div class="row nomargin ind_typ">
                    <div class="col-md-12">
                        <div style="text-left">
                            <asp:Label ID="lblSearchType" runat="server"><%= Resources.Global.ProductSearchTypeText %>:</asp:Label>
                            <br />
                            <asp:RadioButtonList ID="rblSearchType" runat="server" RepeatColumns="3" RepeatDirection="Horizontal" 
                                AutoPostBack="True" CssClass="smallcheck" />
                        </div>
                    </div>
                </div>

                <%--Products--%>
                <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                    <ContentTemplate>
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h4 class="blu_tab">
                                    <a class="clr_wht fontbold">
                                        <%= Resources.Global.Products %>
                                    </a>
                                </h4>
                            </div>
                            <div class="row panel-body nomargin pad10 gray_bg table-responsive">
                                <div class="col-md-12 col-sm-12 col-xs-12">
                                    <asp:CheckBoxList ID="cblProductProvided" runat="server" AutoPostBack="True" RepeatColumns="4" RepeatDirection="Vertical"
                                        RepeatLayout="Table" CssClass="table_bbos norm_lbl nowraptd_wraplabel" Width="100%" />
                                </div>
                            </div>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
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
        function pageLoad() {
            SetShadeRow(document.getElementById('<% =cblProductProvided.ClientID %>'));
            btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');
        }
    </script>
</asp:Content>