<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CustomFieldCompanyBulkEdit.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CustomFieldCompanyBulkEdit" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin_lr mar_bot">
        <div class="col-md-12 nopadding">
            <div class="row Title">
                <%=Resources.Global.SelectedCompaniesUpdatedOnlyWithSelectedFields%>  <%--The selected companies will be updated only with the selected fields.--%>
            </div>
        </div>

        <div class="col-md-12 nomargin_lr space ind_typ gray_bg">
            <asp:Repeater OnItemCreated="RepCustomFields_ItemCreated" ID="repCustomFields" runat="server">
                <ItemTemplate>
                    <asp:PlaceHolder ID="phCustomField" runat="server" />
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <div class="row nomargin_lr">
            <div class="col-md-12 nopadding">
                <div class="srch_btns">
                    <asp:LinkButton ID="btnSave" runat="server" CssClass="btn gray_btn" OnClick="btnSaveOnClick">
	                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnSave %>" />
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancelOnClick">
	                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnCancel %>" />
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnNewCustomData" runat="server" CssClass="btn gray_btn" OnClick="btnNewCustomDataOnClick">
	                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnNewCustomData %>" />
                    </asp:LinkButton>
                </div>
            </div>
        </div>

        <div class="row mar_bot mar_top">
            <asp:Label ID="lblRecordCount" runat="server" CssClass="RecordCnt" />
        </div>

        <div class="row nomargin_lr">
            <div class="col-md-12 nopadding">
                <div class="table-responsive">
                    <asp:GridView ID="gvSelectedCompanies"
                        AllowSorting="false"
                        runat="server"
                        AutoGenerateColumns="false"
                        CssClass="sch_result table table-striped table-hover"
                        GridLines="none"
                        DataKeyNames="comp_CompanyID"
                        HeaderStyle-Height="33px"
                        ShowFooter="false">

                        <Columns>
                            <%--BBNumber Column--%>
                            <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="text-nowrap vertical-align-top"
                                DataField="comp_CompanyID" SortExpression="comp_CompanyID" />

                            <%--Icons Column--%>
                            <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
                                <ItemTemplate>
                                    <%# GetCompanyDataForCell((int)Eval("comp_CompanyID"), 
                                (string)Eval("comp_PRBookTradestyle"), 
                                (string)Eval("comp_PRLegalName"), 
                                UIUtils.GetBool(Eval("HasNote")), 
                                UIUtils.GetDateTime(Eval("comp_PRLastPublishedCSDate")), 
                                (string)Eval("comp_PRListingStatus"), 
                                true, 
                                UIUtils.GetBool(Eval("HasNewClaimActivity")), 
                                UIUtils.GetBool(Eval("HasMeritoriousClaim")), 
                                UIUtils.GetBool(Eval("HasCertification")), 
                                UIUtils.GetBool(Eval("HasCertification_Organic")), 
                                UIUtils.GetBool(Eval("HasCertification_FoodSafety")), 
                                true, 
                                false)%>
                                    <br />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%--Company Name column--%>
                            <asp:TemplateField HeaderText="<%$ Resources:Global, CompanyName %>" HeaderStyle-CssClass="vertical-align-top" SortExpression="comp_PRBookTradestyle">
                                <ItemTemplate>
                                    <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                                    <asp:Literal ID="litLegalName" runat="server" Text='<%# PageBase.ParenWrap(Eval("comp_PRLegalName"))%>' />
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left" DataField="CityStateCountryShort"
                                SortExpression="CityStateCountryShort" />

                            <asp:BoundField HeaderText="<%$ Resources:Global, Industry %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left" DataField="IndustryType"
                                SortExpression="IndustryType" />

                            <%--Type/Industry Column--%>
                            <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" ItemStyle-CssClass="text-left vertical-align-top" SortExpression="CompanyType">
                                <HeaderTemplate>
                                    <asp:Label ID="lbTypeIndustryColHeader" runat="server" Text='<%$ Resources:Global, Type %>' />
                                    &nbsp;
                                        <a id="popWhatIsIndustry" runat="server" class="clr_blc cursor_pointer" data-bs-html="true" style="color: #000;" data-bs-toggle="modal" data-bs-target="#pnlIndustry">
                                            <asp:Image runat="server" ImageUrl="images/info_sm.png" ToolTip="<%$ Resources:Global, WhatIsThis %>" />
                                        </a>
                                </HeaderTemplate>

                                <ItemTemplate>
                                    <%# PageControlBaseCommon.GetCompanyType((string)Eval("CompanyType"), Eval("comp_PRLocalSource"))%>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>

                    <div id="pnlIndustry" class="modal fade" role="dialog">
                        <div class="modal-dialog">
                            <!-- Modal content-->
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-bs-dismiss="modal">&times;</button>
                                </div>
                                <div class="modal-body">
                                    <span class="sml_font">
                                        <%= Resources.Global.IndustryHelp %>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
</asp:Content>
