<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="MembershipSummary.aspx.cs" Inherits="PRCo.BBOS.UI.Web.MembershipSummary" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="EMCW_CompanyHeader" Src="~/UserControls/EMCW_CompanyHeader.ascx" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <bbos:EMCW_CompanyHeader ID="ucCompanyDetailsHeader" runat="server" />

     <div class="row nomargin panels_box">
        <div class="row nomargin">
            <div class="col-md-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h4 class="blu_tab"><% =Resources.Global.AccountContactInformation %></h4>
                    </div>

                    <div class="panel-body nomargin pad10">
                        <div class="form-group">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="col-md-4">
                                        <div class="clr_blu nopadding_tb"><% =Resources.Global.RatingRepresentative %>:</div>
                                    </div>
                                    <div class="col-md-8 form-inline">
                                        <asp:Literal ID="litRatingRep" runat="server" />
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="col-md-4">
                                        <div class="clr_blu nopadding_tb"><% =Resources.Global.CustomerServiceRepresentative %>:</div>
                                    </div>
                                    <div class="col-md-8 form-inline">
                                        <asp:Literal ID="litCSRep" runat="server" />
                                    </div>
                                </div>
                            </div>
                            <div class="row mar_top_10">
                                <div class="col-md-6">
                                    <div class="col-md-4">
                                        <div class="clr_blu nopadding_tb"><% =Resources.Global.SalesRepresentative %>:</div>
                                    </div>
                                    <div class="col-md-8 form-inline">
                                        <asp:Literal ID="litSaleRep" runat="server" />
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="col-md-4">
                                        <div class="clr_blu nopadding_tb"><% =Resources.Global.ListingSpecialists %>:</div>
                                    </div>
                                    <div class="col-md-8 form-inline">
                                        630 668-3500
                                        <br />
                                        <a href="mailto:listing@bluebookservices.com" class="explicitlink">listing@bluebookservices.com</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mar_top nomargin_lr">
            <div class="col-md-12">
                <asp:LinkButton ID="btnUpgradeMembership" runat="server" CssClass="btn gray_btn" OnClick="btnUpgradeMembershipOnClick">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, UpgradeMembership %>" />
                </asp:LinkButton>
                <asp:LinkButton ID="btnPurchaseAdditionalUnits" runat="server" CssClass="btn gray_btn" OnClick="btnPurchaseAdditionalUnitsOnClick">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, PurchaseAdditionalReports %>" />
                </asp:LinkButton>
                <asp:LinkButton ID="btnPurchaseExpressUpdates" runat="server" CssClass="btn gray_btn" OnClick="btnPurchaseExpressUpdatesOnClick">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, PurchaseExpressUpdates %>" />
                </asp:LinkButton>
                <asp:LinkButton ID="btnPurchaseLSSAccess" runat="server" CssClass="btn gray_btn" OnClick="btnPurchaseLSSAccessOnClick">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, PurchaseLocalSourceLicense %>" />
                </asp:LinkButton>
                <asp:LinkButton ID="btnUserAccessList" runat="server" CssClass="btn gray_btn" OnClick="btnUserAccessListOnClick">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, PersonnelList %>" />
                </asp:LinkButton>
                <asp:LinkButton ID="btnAdCampaigns" runat="server" CssClass="btn gray_btn" OnClick="btnAdCampaignOnClick">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, AdvertisingCampaigns %>" />
                </asp:LinkButton>
            </div>
        </div>
    </div>

    <div class="row nomargin panels_box">
        <div class="row nomargin">
            <div class="col-md-12">
                <div class="panel panel-primary">
                    <div class="panel-heading">
                        <h4 class="blu_tab"><% =Resources.Global.AnnualSubscriptionServices %></h4>
                    </div>

                    <div class="panel-body nomargin pad10">
                        <asp:GridView ID="gvServices" 
                            runat="server" 
                            GridLines="none" 
                            AutoGenerateColumns="false"
                            AllowSorting="true" 
                            Width="100%"
                            CellSpacing="3" 
                            CssClass="table table-striped table-hover tab_bdy" 
                            OnRowDataBound="GridView_RowDataBound"
                            OnSorting="GridView_Sorting">

                            <Columns>
                                <asp:BoundField HeaderText="<%$ Resources:Global, ServiceName %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap" DataField="Name" SortExpression="Name" />
                                <asp:BoundField HeaderText="<%$ Resources:Global, Quantity %>" DataFormatString="{0:0}" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap" DataField="QuantityOrdered" SortExpression="QuantityOrdered" />
                                <asp:TemplateField ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="text-left vertical-align-top" HeaderText="<%$ Resources:Global, AnniversaryDate %>" SortExpression="prse_NextAnniversaryDate">
                                    <ItemTemplate>
                                        <%# PageBase.GetStringFromDate(Eval("prse_NextAnniversaryDate"))%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap" DataField="CityStateCountryShort" SortExpression="CityStateCountryShort"/>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <asp:Panel ID="pnlUsageHistory" runat="server">
        <div class="row nomargin panels_box">
            <div class="row nomargin">
                <div class="col-md-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            <h4 class="blu_tab">
                                <asp:Literal ID="litUsageHistory" runat="server" /></h4>
                        </div>

                        <div class="panel-body nomargin pad10">
                            <asp:GridView ID="gvUsageHistory"
                                runat="server"
                                GridLines="none"
                                AutoGenerateColumns="false"
                                AllowSorting="true"
                                Width="100%"
                                CellSpacing="3"
                                CssClass="table table-striped table-hover tab_bdy"
                                OnRowDataBound="GridView_RowDataBound"
                                OnSorting="GridView_Sorting">

                                <Columns>
                                    <asp:BoundField HeaderText="<%$ Resources:Global, PersonName %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top" DataField="FullName" SortExpression="pers_LastName" />
                                    <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top" DataField="CityStateCountryShort" SortExpression="CityStateCountryShort" />

                                    <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left vertical-align-top" HeaderText="<%$ Resources:Global, UsageDate %>" SortExpression="prsuu_CreatedDate">
                                        <ItemTemplate>
                                            <%# PageBase.GetStringFromDate(Eval("prsuu_CreatedDate"))%>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left vertical-align-top" HeaderText="<%$ Resources:Global, Type %>">
                                        <ItemTemplate>
                                            <%# GetType((DateTime)Eval("prsuu_CreatedDate"), (string)Eval("prsuu_UsageTypeCode")) %>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left vertical-align-top" HeaderText="<%$ Resources:Global, SubjectCompany %>">
                                        <ItemTemplate>
                                            <%# GetAddtionalInfo((string)Eval("prsuu_UsageTypeCode"), Eval("prsuu_RegardingObjectID"), Eval("RequestedCompanyName"))%>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlAllocationHistory" runat="server">
        <div class="row nomargin panels_box">
            <div class="row nomargin">
                <div class="col-md-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            <h4 class="blu_tab"><% =Resources.Global.AvailableServiceUnitsSummary %></h4>
                        </div>

                        <div class="panel-body nomargin pad10">
                            <asp:GridView ID="gvAllocationHistory"
                                runat="server"
                                GridLines="none"
                                AutoGenerateColumns="false"
                                CellSpacing="3"
                                CssClass="table table-striped table-hover tab_bdy"
                                ShowFooter="true"
                                OnRowDataBound="GridView_RowDataBound">

                                <Columns>
                                    <asp:BoundField HeaderText="<%$ Resources:Global, AllocationType %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="vertical-align-top" DataField="AllocationType" SortExpression="AllocationType" />
                                    <asp:BoundField HeaderText="<%$ Resources:Global, Location  %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="vertical-align-top" DataField="CityStateCountryShort" SortExpression="CityStateCountryShort" />
                                    <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="vertical-align-top text-left" HeaderText="<%$ Resources:Global, ExpirationDate %>" FooterStyle-CssClass="text-left bold" SortExpression="prun_ExpirationDate">
                                        <ItemTemplate>
                                            <%# PageBase.GetStringFromDate(Eval("prun_ExpirationDate"))%>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:BoundField HeaderText="<%$ Resources:Global, TotalReports %>" ItemStyle-CssClass="text-left" FooterStyle-CssClass="text-left bold" HeaderStyle-CssClass="vertical-align-top" DataField="prun_UnitsAllocated" SortExpression="prun_UnitsAllocated" DataFormatString="{0:N0}" HtmlEncode="false" />
                                    <asp:BoundField HeaderText="<%$ Resources:Global, ReportsUsed %>" ItemStyle-CssClass="text-left" FooterStyle-CssClass="text-left bold" HeaderStyle-CssClass="vertical-align-top" DataField="UnitsUsed" SortExpression="UnitsUsed" DataFormatString="{0:N0}" HtmlEncode="false" />
                                    <asp:BoundField HeaderText="<%$ Resources:Global, RemainingReports %>" ItemStyle-CssClass="text-left" FooterStyle-CssClass="text-left bold" HeaderStyle-CssClass="vertical-align-top" DataField="prun_UnitsRemaining" SortExpression="prun_UnitsRemaining" DataFormatString="{0:N0}" HtmlEncode="false" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlExportUsage" runat="server" Visible="false">
        <div class="row nomargin panels_box">
            <div class="row nomargin">
                <div class="col-md-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            <h4 class="blu_tab"><% =Resources.Global.ExportUsage %></h4>
                        </div>

                        <div class="panel-body nomargin pad10">
                            <asp:GridView ID="gvExportUsage"
                                runat="server"
                                GridLines="none"
                                AutoGenerateColumns="false"
                                CellSpacing="3"
                                CssClass="table table-striped table-hover tab_bdy"
                                ShowFooter="true"
                                OnRowDataBound="GridView_RowDataBound" 
                                >
                                <Columns>
                                    <asp:BoundField HeaderText="Person Name" ItemStyle-Width="20%" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="vertical-align-top" DataField="Person Name" />
                                    <asp:BoundField HeaderText="Location" ItemStyle-Width="20%" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="vertical-align-top" DataField="Location" />

                                    <asp:BoundField HeaderText="Month" ItemStyle-Width="20%" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="vertical-align-top" DataField="Month" />
                                    <asp:BoundField HeaderText="Export Count" ItemStyle-Width="40%" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="vertical-align-top" DataField="ExportCount" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlBusinessValuation" runat="server" Visible="false">
        <div class="row nomargin panels_box">
            <div class="row nomargin">
                <div class="col-md-12">
                    <div class="panel panel-primary">
                        <div class="panel-heading">
                            <h4 class="blu_tab"><% =Resources.Global.BusinessValuation %></h4>
                        </div>

                        <div class="panel-body nomargin pad10">
                            <asp:GridView ID="gvBusinessValuation"
                                runat="server"
                                GridLines="none"
                                AutoGenerateColumns="false"
                                CellSpacing="3"
                                CssClass="table table-striped table-hover tab_bdy"
                                ShowFooter="true"
                                OnRowDataBound="gvBusinessValuation_RowDataBound"
                                >
                                <Columns>
                                    <asp:BoundField HeaderText="<%$Resources:Global,RequestDate %>" ItemStyle-Width="25%" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="vertical-align-top" DataField="prbv_CreatedDate" />
                                    <asp:BoundField HeaderText="<%$Resources:Global,RequestBy %>" ItemStyle-Width="25%" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="vertical-align-top" DataField="Created By" />
                                    <asp:BoundField HeaderText="<%$Resources:Global,Status %>" ItemStyle-Width="25%" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="vertical-align-top" DataField="Status" />
                                    <asp:TemplateField HeaderText="<%$ Resources:Global, Download%>">
                                        <ItemTemplate>
                                            <asp:Literal ID="litDownloadLink" runat="server" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>
</asp:Content>