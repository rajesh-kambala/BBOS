<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanySearchCustom.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanySearchCustom" EnableEventValidation="false" %>

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
                            <asp:AsyncPostBackTrigger ControlID="chkCompanyHasNotes" EventName="CheckedChanged" />
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
                                    <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                                        <ContentTemplate>
                                            <asp:RadioButtonList ID="rblIndustryType" runat="server" RepeatColumns="3" AutoPostBack="True"
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

                <asp:Panel ID="pnlCustomIdentifier" runat="server">
                    <div class="col-md-12 nopadding ind_typ gray_bg mar_top_15 px-2">
                        <div class="col-md-9">
                            <asp:CheckBox ID="chkCompanyHasNotes" runat="server" AutoPostBack="true" Text="<%$Resources:Global, CompanyHasNotes  %>" />
                        </div>
                    </div>
                </asp:Panel>

                <div class="row nomargin_lr">
                    <div class="col-md-12 nopadding space ind_typ gray_bg mar_top">
                        <asp:Repeater OnItemCreated="RepCustomFields_ItemCreated" ID="repCustomFields" runat="server">
                            <ItemTemplate>
                                <asp:PlaceHolder ID="phCustomField" runat="server" />
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <div class="row nomargin">
                    <div class="col-md-12 mar_top">
                        <asp:Panel ID="pnlWatchdogList" runat="server">
                            <div class="row clr_blu mar_bot">
                                <div class="col-md-12">
                                    <%= Resources.Global.SelectWatchdogListsText %>:
                                </div>
                            </div>

                            <div class="pad5">
                                <asp:GridView ID="gvUserList"
                                    AllowSorting="true"
                                    runat="server"
                                    AutoGenerateColumns="false"
                                    CssClass="table table-striped table-hover"
                                    GridLines="None"
                                    OnSorting="UserListGridView_Sorting"
                                    OnRowDataBound="GridView_RowDataBound">

                                    <Columns>
                                        <asp:TemplateField HeaderStyle-CssClass="vertical-align-top text-center" ItemStyle-CssClass="text-center">
                                            <HeaderTemplate>
                                                <% =Resources.Global.Select%>
                                                <br />
                                                <% =GetCheckAllCheckbox("cbUserListID")%>
                                            </HeaderTemplate>

                                            <ItemTemplate>
                                                <input type="checkbox" name="cbUserListID" value="<%# Eval("prwucl_WebUserListID") %>"
                                                    <%# GetChecked((int)Eval("prwucl_WebUserListID")) %> onclick="refreshCriteria();" />
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="<%$ Resources:Global, WatchdogListName %>" ItemStyle-CssClass="text-left" SortExpression="prwucl_Name" HeaderStyle-CssClass="vertical-align-top">
                                            <ItemTemplate>
                                                <a href="<%# PageConstants.Format(PageConstants.USER_LIST, Eval("prwucl_WebUserListID")) %>">
                                                    <%# PageControlBaseCommon.GetCategoryIcon(Eval("prwucl_CategoryIcon"), Eval("prwucl_Name"))%> <%# Eval("prwucl_Name")%>
                                                </a>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, Private %>" SortExpression="prwucl_IsPrivate">
                                            <ItemTemplate><%# UIUtils.GetStringFromBool(Eval("prwucl_IsPrivate"))%> </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="vertical-align-top" HeaderText="<%$ Resources:Global, UpdatedDate %>" SortExpression="UpdatedDate">
                                            <ItemTemplate><%# GetStringFromDate(Eval("UpdatedDate"))%> </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField HeaderText="<%$ Resources:Global, CompanyCount %>" DataField="CompanyCount" SortExpression="CompanyCount" HeaderStyle-CssClass="vertical-align-top" ItemStyle-CssClass="text-left vertical-align-top" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </asp:Panel>
                    </div>
                </div>

                <div class="row">
                    <p>
                        <% =GetSearchButtonMsg() %>
                    </p>
                </div>
            </div>
        </div>
    </asp:Panel>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');

        function refreshCriteria() {
        <%=ClientScript.GetPostBackEventReference(UpdatePanel1, "")%>;
        }

        var cbCheckAll = document.getElementById('cbCheckAll');
        cbCheckAll.addEventListener('click', refreshCriteria);
    </script>
</asp:Content>
