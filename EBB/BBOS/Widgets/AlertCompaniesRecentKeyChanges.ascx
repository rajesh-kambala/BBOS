<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AlertCompaniesRecentKeyChanges.ascx.cs" Inherits="PRCo.BBOS.UI.Web.Widgets.AlertCompaniesRecentKeyChanges" %>
<div class="bbs-list-panel">
    <div class="bbs-list-panel-heading">
        <h3 style="margin-right: auto"><%=Resources.Global.AlertCompaniesWithRecentKeyChanges %></h3>
        <h3 style="margin-left: auto; font-size:smaller; white-space:nowrap;">
            <nobr><asp:HyperLink ID="hlChangeWidgets" runat="server" NavigateUrl="~/UserProfile.aspx" Text='<%$ Resources:Global, ChangeWidgets %>'  /></nobr>
        </h3>
        <br style="clear:both;" />
    </div>
    <div class="bbs-list-group">
        <div class="col-12">
            <asp:GridView ID="gvSearchResults"
                AllowSorting="false"
                runat="server"
                AutoGenerateColumns="false"
                CssClass="table table-striped table-hover"
                GridLines="None"
                SortField="comp_PRBookTradestyle"
                DataKeyNames="comp_CompanyID">

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

                    <%--Date Column--%>
                    <asp:BoundField HeaderText="<%$ Resources:Global, DatePublished %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" DataField="prcs_PublishableDate" DataFormatString="{0:MM/dd/yyyy}" SortExpression="prcs_PublishableDate" />
                </Columns>
            </asp:GridView>

            <div class="row nomargin pad10 text-left">
                <asp:LinkButton ID="btnAlerts" runat="server" CssClass="bbsButton bbsButton-secondary full-width" OnClick="btnAlerts_Click">
		              <span class="msicon notranslate">visibility</span>
                  <span><asp:Literal runat="server" Text="<%$ Resources:Global, ViewAll %>" /></span>
                </asp:LinkButton>
            </div>
        </div>
    </div>
</div>