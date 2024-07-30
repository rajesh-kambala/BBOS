<%@ Page Title="" Language="C#" MasterPageFile="~/BBSI.master" AutoEventWireup="true" CodeBehind="CompanyAdvertising.aspx.cs" Inherits="BBOSMobileSales.CompanyAdvertising" %>

<%@ Register TagPrefix="bbos" TagName="CompanyHeader" Src="UserControls/CompanyHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyFooter" Src="UserControls/CompanyFooter.ascx" %>


<asp:Content ID="Content1" ContentPlaceHolderID="Content1" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Content2" runat="server">
    <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
    <bbos:CompanyHeader ID="ucCompanyHeader" runat="server" />

    <asp:Panel ID="pnlAdRevenue" runat="server">
        <div class="card mt-2">
            <div class="card-body card-body-sm">
                <h5 class="card-title mt-0">Revenue in Past 12 Months</h5>

                <div class="row panel-collapse collapse show" id="revenue">
                    <div class="table-responsive">
                        <table class="table table-sm table-striped">
                            <tr>
                                <th>Campaign Type</th>
                                <th class="text-right">Cost</th>
                            </tr>
                            <asp:Repeater ID="repAdRevenue" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Eval("CampaignType") %></td>
                                        <td class="text-right"><%# Eval("Cost", "{0:C0}") %></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>

                            <tr>
                                <th class="text-right">Totals:</th>
                                <th class="text-right">
                                    <asp:Literal ID="litTotal" runat="server"></asp:Literal></th>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlImageAd" runat="server">
        <div class="card mt-2">
            <div class="card-body card-body-sm">
                <h5 class="card-title mt-0">Online Ads in Past 12 Months</h5>

                <div class="row panel-collapse collapse show" id="onlineAds">
                    <div class="table-responsive">
                        <table class="table table-sm table-striped">
                            <tr>
                                <th>Campaign Name</th>
                                <th class="text-right">Impression Count</th>
                                <th class="text-right">Click Count</th>
                            </tr>

                            <asp:Repeater ID="repImageAd" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Eval("pradc_Name") %></td>
                                        <td class="text-right"><%# string.Format(Eval("ImpressionCount", "{0:###,##0}")) %></td>
                                        <td class="text-right"><%# string.Format(Eval("ClickCount", "{0:###,##0}")) %></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>

                            <tr>
                                <th class="text-right">Totals:</th>
                                <th class="text-right">
                                    <asp:Literal ID="litImpressionCount" runat="server" /></th>
                                <th class="text-right">
                                    <asp:Literal ID="litClickCount" runat="server" /></th>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlAdvertising" runat="server">
        <div class="card mt-2">
            <div class="card-body card-body-sm">
                <h5 class="card-title mt-0">Ad Campaigns</h5>
                <div class="row" id="adDetails">
                    <asp:Panel ID="pnlAdCampaigns" runat="server" Visible="true">
                        <asp:Repeater ID="repAdvertising" runat="server">
                            <ItemTemplate>
                                <div class="card mt-2">
                                    <div class="card-body">
                                        <h5 class="card-title"><%# Eval("pradc_AdCampaignType") %></h5>
                                        <h6 class="card-subtitle text-muted"><%# Eval("pradch_Name") %></h6>
                                        <div class="row card-text mt-2">
                                            <div class="col-5">
                                                <label>Edition:</label>
                                            </div>
                                            <div class="col-7"><%# Eval("BluePrintsEdition") %></div>
                                            <div class="col-5">
                                                <label>Sub-Section:</label>
                                            </div>
                                            <div class="col-7"><%# Eval("PlannedSection") %></div>
                                            <div class="col-5">
                                                <label>Ad Size:</label>
                                            </div>
                                            <div class="col-7"><%# Eval("pradc_AdSize") %></div>
                                            <div class="col-5">
                                                <label>Cost:</label>
                                            </div>
                                            <div class="col-7"><%# Eval("pradc_Cost", "{0:C0}") %></div>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </asp:Panel>

    <bbos:CompanyFooter ID="CompanyFooter" runat="server" />

</asp:Content>
