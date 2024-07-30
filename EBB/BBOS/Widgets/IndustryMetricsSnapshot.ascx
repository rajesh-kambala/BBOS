<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="IndustryMetricsSnapshot.ascx.cs" Inherits="PRCo.BBOS.UI.Web.Widgets.IndustryMetricsSnapshot" %>
<div class="bbs-list-panel">
    <div class="bbs-list-panel-heading">
        <h3 style="margin-right: auto"><%=Resources.Global.IndustryMetricsSnapshot %></h3>
        <h3 style="margin-left: auto; font-size: smaller; white-space:nowrap;">
            <asp:HyperLink ID="hlChangeWidgets" runat="server" NavigateUrl="~/UserProfile.aspx" Text='<%$ Resources:Global, ChangeWidgets %>'  />
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
                OnRowDataBound="GridView_RowDataBound">

                <Columns>
                    <%--Metric Column--%>
                    <asp:TemplateField HeaderText="<%$ Resources:Global, IndustryMetric %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left">
                        <ItemTemplate>
                            <asp:Literal ID="litMetric" runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%--Count column--%>
                    <asp:TemplateField HeaderText="<%$ Resources:Global, InPast12Months %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left">
                        <ItemTemplate>
                            <asp:HyperLink ID="hlCount" runat="server" CssClass="explicitlink" Text='<%# Eval("Count") %>'></asp:HyperLink>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>
</div>
