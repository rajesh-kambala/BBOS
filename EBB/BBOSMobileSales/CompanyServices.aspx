<%@ Page Title="" Language="C#" MasterPageFile="~/BBSI.master" AutoEventWireup="true" CodeBehind="CompanyServices.aspx.cs" Inherits="BBOSMobileSales.CompanyServices" %>

<%@ Register TagPrefix="bbos" TagName="CompanyHeader" Src="UserControls/CompanyHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyFooter" Src="UserControls/CompanyFooter.ascx" %>


<asp:Content ID="Content1" ContentPlaceHolderID="Content1" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Content2" runat="server">
    <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
    <bbos:CompanyHeader ID="ucCompanyHeader" runat="server" />

    <div class="card mt-2">
        <div class="card-body card-body-sm">
            <h5 class="card-title mt-0">Services</h5>

            <asp:Panel ID="pnlServices" runat="server">
                <div class="" id="services">
                    <div class="table-responsive">
                        <table class="table table-sm">
                            <tr>
                                <th>Service</th>
                                <th class="text-center">Qty</th>
                                <th class="text-center">Anniv Date</th>
                            </tr>
                            <asp:Repeater ID="repServices" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><%# Eval("ItemCodeDescExt") %></td>
                                        <td class="text-center"><%# Eval("QuantityOrdered", "{0:0}") %></td>
                                        <td class="text-center"><%# Eval("prse_NextAnniversaryDate", "{0:MM/dd/yyyy}") %></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </table>
                    </div>
                    <div class="row">
                        <div class="col-8">
                            <label>OUTSTANDING BALANCE:</label>
                        </div>
                        <div class="col-4">
                            <asp:Literal ID="litOutstandingBalance" runat="server"></asp:Literal>
                        </div>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>

    <div class="card mt-2">
        <div class="card-body card-body-sm">
            <h5 class="card-title mt-0">Last 12 Mos Service Usage</h5>

            <div class="row panel-collapse show " id="serviceUsage">
                <asp:Repeater ID="repSalesInfo" runat="server">
                    <ItemTemplate>
                        <div class="col-8">
                            <label><%# Eval("FactName") %>:</label>
                        </div>
                        <div class="col-4">
                            <%# Eval("FactValue") %>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <bbos:CompanyFooter ID="CompanyFooter" runat="server" />

</asp:Content>