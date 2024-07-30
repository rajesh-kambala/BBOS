<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CommoditiesList.ascx.cs" Inherits="PRCo.BBOS.UI.Web.CommoditiesList" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Label ID="hidCompanyID" Visible="false" runat="server" />
<asp:Label ID="hidIndustryType" Visible="false" runat="server" />
<asp:Label ID="hidSortBy" Visible="false" runat="server" Text="Description" />

<%--Classifications--%>
<a name="CommoditiesList" class="anchor"></a>
<div class="col-md-12 nopadding_lr" id="pnlCommodities1" runat="server">
    <div class="panel panel-primary">
        <div class="panel-heading">
            <h4 class="blu_tab"><%= Resources.Global.Commodities %>
                &nbsp;
                <asp:ImageButton ID="btnPrint" runat="server" ImageUrl="~/images/print.png" ToolTip="<%$ Resources:Global, Print %>" Visible="true" CssClass="vertical-align-middle" OnClick="btnPrint_Click" />
            </h4>
        </div>
        <div class="panel-body nomargin pad10">
            <div class="row">
                <asp:Repeater ID="repCommodities1" runat="server" OnItemDataBound="repCommodities_ItemDataBound">
                    <ItemTemplate>
                        <div class="col-xs-6 col-sm-4 col-md-4 col-lg-3 vertical-align-top">
                            <asp:HyperLink ID="aDescription" runat="server" NavigateUrl="~/GetPublicationFile.aspx" Text='<%# DataBinder.Eval(Container.DataItem, "Description") %>' Target="_blank" CssClass="explicitlink" />
                            <asp:Literal ID="litDescription" runat="server" Text='<%# DataBinder.Eval(Container.DataItem, "Description") %>' />
                            (<asp:Literal ID="litAbbrev" runat="server" Text='<%# DataBinder.Eval(Container.DataItem, "prcca_PublishedDisplay") %>' />)
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>
</div>

<div class="accordion-item" id="pnlCommodities2" runat="server">
    <div class="accordion-header">
        <button
            class="accordion-button collapsed"
            type="button"
            data-bs-toggle="collapse"
            data-bs-target="#flush_Commodities"
            aria-expanded="false"
            aria-controls="flush_Commodities">
            <h5><%=Resources.Global.Commodities %></h5>
        </button>
    </div>
    <div
        id="flush_Commodities"
        class="accordion-collapse collapse tw-p-4">
        <div class="bbs-card">
            <div class="tw-flex tw-justify-end">
                <button
                    tabindex="0"
                    class="bbsButton bbsButton-tertiary tw-right-0"
                    id="btnPrint2" runat="server"
                    onserverclick="btnPrint2_ServerClick">
                    <span class="msicon notranslate">print</span>
                    <span class="text-label"><%=Resources.Global.Print %></span>
                </button>
            </div>
            <div class="bbs-card-body tw-grid tw-gap-x-4 md:tw-grid-cols-2 lg:tw-grid-cols-3" id="commodities_list">
                <asp:Repeater ID="repCommodities2" runat="server" OnItemDataBound="repCommodities_ItemDataBound">
                    <ItemTemplate>
                        <div>
                            <asp:HyperLink ID="aDescription" runat="server" NavigateUrl="~/GetPublicationFile.aspx" Text='<%# DataBinder.Eval(Container.DataItem, "Description") %>' Target="_blank" CssClass="explicitlink" />
                            <asp:Literal ID="litDescription" runat="server" Text='<%# DataBinder.Eval(Container.DataItem, "Description") %>' />
                            (<asp:Literal ID="litAbbrev" runat="server" Text='<%# DataBinder.Eval(Container.DataItem, "prcca_PublishedDisplay") %>' />)
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>
</div>
