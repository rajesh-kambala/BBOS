<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="RecentCompanies.ascx.cs" Inherits="BBOSMobileSales.UserControls.RecentCompanies" %>

<div class="card">
    <div class="card-body card-body-sm data-list">
        <h5 class="card-title mt-0">Recent Companies</h5>

        <asp:Repeater ID="repCompany" runat="server">
            <ItemTemplate>
                <div class="row data-row">
                    <div class="col-12">
                        <asp:HyperLink ID="hlCompany" runat="server" Text='<%#Eval("comp_PRBookTradestyle")%>'
                            NavigateUrl='<%# Eval("comp_CompanyID", "../CompanyView.aspx?CompanyID={0}")%>' />
                        <br />
                        <asp:Literal ID="litCityState" runat="server" Text='<%#Eval("CityStateCountryShort")%>' />
                        <br />
                        <asp:Literal ID="litIndustryType" runat="server" Text='<%#Eval("comp_PRIndustryType") %>' />
                        <asp:Literal ID="litHQ" runat="server" Text='<%#Eval("comp_PRType") %>'   />
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</div>