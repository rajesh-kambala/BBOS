<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyDetailsBranches.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyDetailsBranches" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls\CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeaderMeister" Src="UserControls/CompanyDetailsHeaderMeister.ascx" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Label ID="hidCompanyID" Visible="false" runat="server" />

    <div class="row nomargin panels_box">
        <div class="row nomargin">
            <div class="col-lg-5 col-md-5 col-sm-12 nopadding_l">
                <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" hideLocation="true" runat="server" />
            </div>
        </div>

        <bbos:CompanyDetailsHeaderMeister ID="ucCompanyDetailsHeaderMeister" runat="server" />

        <%--Buttons row--%>
        <div class="row nomargin_lr mar_top_5">
            <div class="col-md-8 offset-md-4">
                    <div class="col-md-12 search_crit">
                        <a id="btnBranches" class="btn gray_btn btnWidthStd" href="#Branches" style="width:150px;">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<%= Resources.Global.Branches %>
                        </a>

                        <a id="btnAffiliations" class="btn gray_btn btnWidthStd" href="#Affiliations" style="width:150px;">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<%= Resources.Global.Affiliations %>
                        </a>
                    </div>
            </div>
        </div>

        <div class="col-md-12 text-center mar_top">
            <span style="font-weight: bold;">
                <asp:Literal runat="server" Text="<%$ Resources:Global, Headquarters %>" />
            </span>
            <br />
            <% =Resources.Global.BBNumber %><asp:Literal ID="litBBID" runat="server" />
            <br />
            <asp:HyperLink ID="hlHQName" runat="server" CssClass="explicitlink" /><br />
            <asp:Literal ID="litLocation" runat="server" />
        </div>

        <%--Branches--%>
        <div class="col-md-12 text-center mar_top nopadding_lr">
            <asp:UpdatePanel runat="server">
                <ContentTemplate>
                    <p></p>
                    <a name="Branches" class="anchor"></a>

                    <h4 class="blu_tab">
                        <asp:Label ID="lblBranches" CssClass="text-center" Text="<%$ Resources:Global, Branches %>" runat="server" />
                    </h4>

                    <div class="pad5 table-responsive">
                        <asp:GridView ID="gvBranches"
                            AllowSorting="true"
                            runat="server"
                            AutoGenerateColumns="false"
                            CssClass="table table-striped table-hover tab_bdy"
                            GridLines="None"
                            OnSorting="BranchesGridView_Sorting"
                            OnRowDataBound="GridView_RowDataBound">

                            <Columns>
                                <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-top">
                                    <HeaderTemplate>
                                        <% =Resources.Global.Select%><br />
                                        <% =GetCheckAllCheckbox("cbBranchID")%>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <input type="checkbox" name="cbBranchID" value="<%# DataBinder.Eval(Container.DataItem, "comp_CompanyID") %>" />
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <%--BBNumber Column--%>
                                <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left" DataField="comp_CompanyID" SortExpression="comp_CompanyID" />

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
                                <asp:TemplateField HeaderStyle-CssClass="text-left vertical-align-top" ItemStyle-CssClass="text-left" HeaderText="<%$ Resources:Global, CompanyName %>" SortExpression="comp_PRBookTradestyle">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                                        <%--<br />
                                        <%# Eval("CityStateCountryShort") %>--%>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left" DataField="CityStateCountryShort" SortExpression="CityStateCountryShort" />
                                <asp:BoundField HeaderText="<%$ Resources:Global, Industry %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left" DataField="IndustryType" SortExpression="IndustryType" />
                                <asp:BoundField HeaderText="<%$ Resources:Global, Phone2 %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left" DataField="Phone" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>

        <div class="col-md-12 text-left nopadding_l">
            <asp:LinkButton CssClass="btn gray_btn" ID="btnReportsBranches" OnClick="btnReportsBranches_Click" runat="server">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnReports %>" />
            </asp:LinkButton>

            <asp:LinkButton CssClass="btn gray_btn" ID="btnExportDataBranches" OnClick="btnExportDataBranches_Click" runat="server">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnExportData %>" />
            </asp:LinkButton>

            <asp:LinkButton CssClass="btn gray_btn" ID="btnAddToWatchdogBranches" OnClick="btnAddToWatchdogBranches_Click" runat="server">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnAddToWatchdogList %>" />
            </asp:LinkButton>
        </div>

        <%--Affiliations--%>
        <div class="col-md-12 text-center mar_top nopadding_lr">
            <asp:UpdatePanel runat="server">
                <ContentTemplate>
                    <a name="Affiliations" class="anchor"></a>
                    <h4 class="blu_tab">
                        <asp:Label ID="lblAffiliations" CssClass="text-center" Text="<%$ Resources:Global, Affiliations %>" runat="server" /></h4>

                    <div class="pad5 table-responsive">
                        <asp:GridView ID="gvAffiliations"
                            AllowSorting="true"
                            runat="server"
                            AutoGenerateColumns="false"
                            CssClass="table table-striped table-hover tab_bdy"
                            GridLines="None"
                            SortField="comp_CompanyID"
                            OnSorting="AffiliationsGridView_Sorting"
                            OnRowDataBound="GridView_RowDataBound">

                            <Columns>
                                <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-top">
                                    <HeaderTemplate>
                                        <% =Resources.Global.Select%><br />
                                        <% =GetCheckAllCheckbox("cbAffiliateID")%>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <input type="checkbox" name="cbAffiliateID" value="<%# DataBinder.Eval(Container.DataItem, "comp_CompanyID") %>" />
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <%--BBNumber Column--%>
                                <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left" DataField="comp_CompanyID" SortExpression="comp_CompanyID" />

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
                                <asp:TemplateField HeaderStyle-CssClass="text-left vertical-align-top" ItemStyle-CssClass="text-left vertical-align-top"
                                    HeaderText="<%$ Resources:Global, CompanyName %>" SortExpression="comp_PRBookTradestyle">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                                        <%--<br />
                                        <%# Eval("CityStateCountryShort") %>--%>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top" DataField="CityStateCountryShort" SortExpression="CityStateCountryShort" />
                                <asp:BoundField HeaderText="<%$ Resources:Global, Industry %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top" DataField="IndustryType" SortExpression="IndustryType" />

                                <%--Type/Industry Column--%>
                                <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" ItemStyle-CssClass="text-left vertical-align-top" SortExpression="CompanyType">
                                    <HeaderTemplate>
                                        <asp:LinkButton ID="lbTypeIndustryColHeader" runat="server" Text="<%$ Resources:Global, Type %>" CommandName="Sort" CommandArgument="CompanyType" />
                                        &nbsp;
                                        <a id="popWhatIsIndustry" runat="server" class="clr_blc cursor_pointer" data-bs-html="true" style="color: #000;" data-bs-toggle="modal" data-bs-target="#pnlIndustry">
                                            <asp:Image runat="server" ImageUrl="images/info_sm.png" ToolTip="<%$ Resources:Global, WhatIsThis %>" />
                                        </a>
                                    </HeaderTemplate>

                                    <ItemTemplate>
                                        <%# Eval("CompanyType")%>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="<%$ Resources:Global, Rating %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top">
                                    <ItemTemplate>
                                        <asp:Literal ID="litRatingLine" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="<%$ Resources:Global, Phone2 %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top" DataField="Phone" />
                                <asp:TemplateField HeaderText="<%$ Resources:Global, WebSite %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top">
                                    <ItemTemplate>
                                        <%# GetCompanyURL(Eval("emai_PRWebAddress")) %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>

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

        <div class="col-md-12 text-left nopadding_l">
            <asp:LinkButton CssClass="btn gray_btn" ID="btnBusinessReport" OnClick="btnBusinessReportOnClick" runat="server">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnGetBusinessReport %>" />
            </asp:LinkButton>

            <asp:LinkButton CssClass="btn gray_btn" ID="btnReports" OnClick="btnReports_Click" runat="server">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnReports %>" />
            </asp:LinkButton>

            <asp:LinkButton CssClass="btn gray_btn" ID="btnExportData" OnClick="btnExportData_Click" runat="server">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnExportData %>" />
            </asp:LinkButton>

            <asp:LinkButton CssClass="btn gray_btn" ID="btnAddToWatchdog" OnClick="btnAddToWatchdog_Click" runat="server">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnAddToWatchdogList %>" />
            </asp:LinkButton>
        </div>

        <div id="pnlRatingDef" style="display: none; width: 400px; height: auto; min-height:300px; position: absolute; z-index: 100;" class="Popup">
            <div class="popup_header">
                <%--<span class="annotation" onclick="document.getElementById('pnlRatingDef').style.display='none';">Close</span>--%>
                <%--<img src="<% =UIUtils.GetImageURL("close.gif") %>" alt="Close" align="middle" onclick="document.getElementById('pnlRatingDef').style.display='none';" />--%>
                <button type="button" class="close" data-bs-dismiss="modal" onclick="document.getElementById('pnlRatingDef').style.display='none';" >&times;</button>
            </div>
            <span id="ltRatingDef"></span>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>
