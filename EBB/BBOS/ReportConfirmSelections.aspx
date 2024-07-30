<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReportConfirmSelections.aspx.cs" Inherits="PRCo.BBOS.UI.Web.ReportConfirmSelections" MasterPageFile="~/BBOS.Master" MaintainScrollPositionOnPostback="true" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
    </script>
    <style>
    .content-container div.row a.gray_btn {
        display: inline;
        width: auto;
        margin-right: 10px;
        margin-bottom: 20px;
    }
        td a {
            display:inline;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:HiddenField ID="hidTriggerPage" runat="server" />

    <div class="col-md-12">
        <div class="row Title" style="margin-bottom: 15px;"><nobr>
            <asp:Literal ID="litHeaderText" runat="server" /></nobr>
            &nbsp;&nbsp;<% =Resources.Global.ConfirmSelectionsBelow %>
        </div>

        <div class="row">
            <div class="row nomargin panels_box">
                <div class="row nomargin">
                    <div class="col-md-4">
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h4 class="blu_tab"><%= Resources.Global.SelectReport%></h4>
                            </div>
                            <div class="panel-body nomargin pad10">
                                <div class="row nomargin space">
                                    <asp:RadioButtonList ID="rblReportType" runat="server" AutoPostBack="True" CssClass="smallcheck" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <asp:UpdatePanel ID="UpdatePanel1" class="col-md-8" runat="server">
                        <ContentTemplate>
                            <div class="col-md-6">
                                <div class="panel panel-primary">
                                    <div class="panel-heading">
                                        <h4 class="blu_tab"><%= Resources.Global.ReportOptions%></h4>
                                    </div>
                                    <div class="panel-body nomargin pad10">
                                        <div class="row">
                                            <div class="col-md-4">
                                                <asp:Label ID="lblCustomHeaderText" CssClass="clr_blu" for="<%= txtCustomHeader.ClientID%>"  runat="server"><%= Resources.Global.CustomHeaderText %>:</asp:Label>
                                            </div>
                                            <div class="col-md-8">
                                                <asp:TextBox ID="txtCustomHeader" runat="server" CssClass="form-control"/>
                                            </div>
                                        </div>
                                        <div class="row mar_top_5">
                                            <div class="col-md-4">
                                                <asp:Label ID="lblSortOption" CssClass="clr_blu" for="<%= ddlSortOption.ClientID%>" runat="server" Enabled="false"><%= Resources.Global.SortOption %>:</asp:Label>
                                            </div>
                                            <div class="col-md-8">
                                                <asp:DropDownList CssClass="form-control" ID="ddlSortOption" runat="server" Enabled="false">
                                                    <asp:ListItem Text="" Value="" Selected="True" />
                                                    <asp:ListItem Text="<%$ Resources:Global, BBID%>" Value="BBID" />
                                                    <asp:ListItem Text="<%$ Resources:Global, CompanyName%>" Value="CompanyName" />
                                                    <asp:ListItem Text="<%$ Resources:Global, LocationCityState%>" Value="LocationCityState" />
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="rblReportType" EventName="SelectedIndexChanged" />
                        </Triggers>
                    </asp:UpdatePanel>
                </div>
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlMsg" Style="margin-top: 15px; margin-bottom: 15px; margin-left: auto; margin-right: auto; width: 800px; text-align: left;" Visible="false" runat="server">
        <asp:Literal ID="litMsg" runat="server" Text="<%$Resources:Global, LocalSourceDataProvidedByMeisterNotIncluded %>" />
    </asp:Panel>

    <div class="row"></div>

    <%--Buttons--%>
    <div class="row nomargin_lr text-left mar_top20">
        <asp:LinkButton ID="btnGenerateReport" runat="server" CssClass="btn gray_btn" OnClick="btnGenerateReport_Click">
	        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, GenerateReport %>" />
        </asp:LinkButton>

        <asp:LinkButton ID="btnReviseSelections" runat="server" CssClass="btn gray_btn" OnClick="btnReviseSelections_Click">
	        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, ReviseSelections %>" />
        </asp:LinkButton>

        <asp:LinkButton ID="btnHome" runat="server" CssClass="btn gray_btn" OnClick="btnHome_Click">
    	    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Home %>" />
        </asp:LinkButton>
    </div>

    <div class="row mar_top">
        <asp:Label ID="lblRecordCount" runat="server" class="RecordCnt" />
    </div>

    <div class="clearfix"></div>

    <div class="table-responsive">
        <asp:GridView ID="gvSelectedCompanies"
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
                <asp:TemplateField HeaderStyle-CssClass="text-left vertical-align-top" HeaderText="<%$ Resources:Global, CompanyName %>" SortExpression="comp_PRBookTradestyle">
                    <ItemTemplate>
                        <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle")%></asp:HyperLink>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left text-nowrap vertical-align-top" DataField="CityStateCountryShort"
                    SortExpression="CountryStAbbrCity" />

                <asp:BoundField HeaderText="<%$ Resources:Global, Industry %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left text-nowrap vertical-align-top" DataField="IndustryType"
                    SortExpression="IndustryType" />

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
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
    </script>
</asp:Content>