<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ListingsRecentlyPublished.ascx.cs" Inherits="PRCo.BBOS.UI.Web.Widgets.ListingsRecentlyPublished" %>
<div class="bbs-list-panel">
    <div class="bbs-list-panel-heading">
        <h3 style="margin-right: auto"><%=Resources.Global.MostRecentlyPublishedListings %></h3>
        <h3 style="margin-left: auto; font-size: smaller; white-space:nowrap;">
            <asp:HyperLink ID="hlChangeWidgets" runat="server" NavigateUrl="~/UserProfile.aspx" Text='<%$ Resources:Global, ChangeWidgets %>' />
        </h3>
        <br style="clear: both;" />
    </div>
    <div class="bbs-list-group">
        <div class="col-12">
            <asp:GridView ID="gvSearchResults"
                AllowSorting="false"
                runat="server"
                AutoGenerateColumns="false"
                CssClass="table table-striped table-hover"
                GridLines="None"
                OnRowDataBound="GridView_RowDataBound"
                SortField="comp_PRBookTradestyle"
                DataKeyNames="comp_CompanyID" >

                <Columns>
                    <%--BBNumber Column--%>
                    <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left" DataField="comp_CompanyID" SortExpression="comp_CompanyID" />

                    <%--Company Name column--%>
                    <asp:TemplateField HeaderText="<%$ Resources:Global, CompanyName %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" SortExpression="comp_PRBookTradestyle">
                        <ItemTemplate>
                            <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%--Location Column--%>
                    <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" DataField="CityStateCountryShort" SortExpression="CountryStAbbrCity" />
                </Columns>
            </asp:GridView>
        </div>
    </div>
</div>
