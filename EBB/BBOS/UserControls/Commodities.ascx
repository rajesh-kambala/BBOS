<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Commodities.ascx.cs" Inherits="PRCo.BBOS.UI.Web.Commodities" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Label ID="hidCompanyID" Visible="false" runat="server" />
<asp:Label ID="hidIndustryType" Visible="false" runat="server" />

<%--Classifications--%>
<div class="col-md-12 text-center nopadding_lr">
    <asp:UpdatePanel ID="updpnlCommodities" runat="server">
        <ContentTemplate>
            <a name="Commodities" class="anchor"></a>

            <h4 class="blu_tab">
                <asp:PlaceHolder ID="phCommodities" runat="server"><%=Resources.Global.Commodities %></asp:PlaceHolder>
            </h4>

            <div class="pad5">
                <asp:GridView ID="gvCommodities"
                    AllowSorting="true"
                    runat="server"
                    AutoGenerateColumns="false"
                    CssClass="table table-striped table-hover tab_bdy"
                    GridLines="None"
                    OnSorting="GridView_Sorting"
                    OnRowDataBound="gvCommodities_GridView_RowDataBound">

                    <Columns>
                        <asp:TemplateField HeaderText="<%$ Resources:Global, Description %>" HeaderStyle-CssClass="text-nowrap explicitlink" SortExpression="Description" ItemStyle-CssClass="text-left" ItemStyle-Width="30%">
                            <ItemTemplate>
                                <asp:HyperLink ID="aDescription" runat="server" NavigateUrl="~/GetPublicationFile.aspx" Text='<%# DataBinder.Eval(Container.DataItem, "Description") %>' Target="_blank" />
                                <asp:Literal ID="litDescription" runat="server" Text='<%# DataBinder.Eval(Container.DataItem, "Description") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField HeaderText="<%$ Resources:Global, Abbreviation %>" HeaderStyle-CssClass="text-nowrap explicitlink" DataField="prcca_PublishedDisplay" SortExpression="prcca_PublishedDisplay" ItemStyle-CssClass="text-left" ItemStyle-Width="70%" />
                    </Columns>
                </asp:GridView>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</div>
