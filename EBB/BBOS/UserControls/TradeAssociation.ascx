<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TradeAssociation.ascx.cs" Inherits="PRCo.BBOS.UI.Web.TradeAssociation" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Panel id="pnlTradeAssoc1" runat="server" Visible="true" CssClass="col4_box">
    <div class="cmp_nme">
        <h4 class="blu_tab"><%=Resources.Global.TradeAssociationMembership %></h4>
    </div>
    <div class="tab_bdy pad10">
        <div class="text-center">
            <%--<img src="images/uf.png" />--%>
            <asp:Literal ID="litTradeAssociations" runat="server" />
            <asp:Literal ID="litTradeAssociationsSpacer" Visible="false" runat="server"><br /><br /> </asp:Literal>
        </div>
    </div>
</asp:Panel>

<asp:Panel ID="pnlTradeAssoc2" runat="server" Visible="false" CssClass="accordion-item">
    <div class="accordion-header">
        <button
            class="accordion-button"
            type="button"
            data-bs-toggle="collapse"
            data-bs-target="#flush_collapseTradeAssociations"
            aria-expanded="false"
            aria-controls="flush_collapseTradeAssociations">
            <h5><%=Resources.Global.TradeAssociationMemberships %></h5>
        </button>
    </div>
    <div
        id="flush_collapseTradeAssociations"
        class="accordion-collapse collapse show tw-p-4">
        <div
            class="tw-flex tw-flex-wrap tw-justify-evenly tw-gap-4">
            <asp:Literal ID="litTradeAssociations2" runat="server" />
        </div>
    </div>
</asp:Panel>
