<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="NewsArticleView.aspx.cs" Inherits="PRCo.BBOS.UI.Web.NewsArticleView" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="Advertisements" Src="UserControls/Advertisements.ascx" %>
<%@ Register TagPrefix="bbos" TagName="WordPressArticle" Src="UserControls/WordPressArticle.ascx" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
    </script>

    <link rel="stylesheet" href="Content/style_wp.min.css" />
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
     <div class="row nomargin panels_box ParagraphBreak">
        <div class="col-lg-10 col-md-9 col-sm-12 col-xs-12">
            <bbos:WordPressArticle ID="ucWordPressArticle" runat="server" ShowDate="true" />
        </div>

        <div class="col-lg-2        col-md-3        col-sm-6        col-xs-12 
                    offset-lg-0 offset-md-0 offset-sm-3 offset-xs-0
                    nopadding">
            <bbos:Advertisements ID="Advertisement" Title="<% $Resources:Global, Advertisement %>" PageName="NewsArticle" MaxAdCount="2" CampaignType="IA,IA_180x90,IA_180x570" runat="server" />
        </div>
    </div>

    <div class="row nomargin panels_box">
        <div class="col-lg-10 col-md-9 col-sm-12 col-xs-12">
            <div class="row nomargin_lr">
                <div class="table-responsive">
                    <asp:GridView ID="gvCompanies"
                        AllowSorting="true"
                        runat="server"
                        AutoGenerateColumns="false"
                        CssClass="sch_result table table-striped table-hover"
                        GridLines="none"
                        OnSorting="GridView_Sorting"
                        OnRowDataBound="GridView_RowDataBound"
                        SortField="comp_PRBookTradestyle"
                        DataKeyNames="comp_CompanyID">

                        <Columns>
                            <asp:TemplateField ItemStyle-CssClass="text-center vertical-align-top" HeaderStyle-CssClass="text-center vertical-align-top">
                                <HeaderTemplate>
                                    <% =Resources.Global.Select%>
                                    <br />
                                    <% =PageBase.GetCheckAllCheckbox("cbCompanyID")%>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <input type="checkbox" name="cbCompanyID" value='<%# Eval("comp_CompanyID") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>

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
                                </ItemTemplate>
                            </asp:TemplateField>

                            <%--Company Name column--%>
                            <asp:TemplateField HeaderText="<%$ Resources:Global, CompanyName %>" HeaderStyle-CssClass="vertical-align-top" SortExpression="comp_PRBookTradestyle">
                                <ItemTemplate>
                                    <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="vertical-align-top"
                                DataField="CityStateCountryShort" SortExpression="CityStateCountryShort" />

                            <asp:BoundField HeaderText="<%$ Resources:Global, Industry %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left vertical-align-top"
                                DataField="IndustryType" SortExpression="IndustryType" />

                            <%--Type/Industry Column--%>
                            <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" ItemStyle-CssClass="text-left vertical-align-top" SortExpression="CompanyType">
                                <HeaderTemplate>
                                    <asp:LinkButton ID="lbTypeIndustryColHeader" runat="server" Text='<%$ Resources:Global, Type %>' CommandName="Sort" CommandArgument="CompanyType" />
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

                <div class="row nomargin text-left mar_top">
                    <asp:LinkButton ID="btnNews" runat="server" CssClass="btn gray_btn" OnClick="btnNews_Click">
		                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, News %>" />
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnBusinessReport" runat="server" CssClass="btn gray_btn" OnClick="btnBusinessReport_Click" Visible="false">
		                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnGetBusinessReport %>" />
                    </asp:LinkButton>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>
