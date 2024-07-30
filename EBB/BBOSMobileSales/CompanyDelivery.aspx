<%@ Page Title="" Language="C#" MasterPageFile="~/BBSI.master" AutoEventWireup="true" CodeBehind="CompanyDelivery.aspx.cs" Inherits="BBOSMobileSales.CompanyDelivery" %>
<%@ Register TagPrefix="bbos" TagName="CompanyHeader" Src="UserControls/CompanyHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyFooter" Src="UserControls/CompanyFooter.ascx" %>


<asp:Content ID="Content1" ContentPlaceHolderID="Content1" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Content2" runat="server">
    <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
    <bbos:CompanyHeader ID="ucCompanyHeader" runat="server" />
    
    <asp:Repeater ID="repAttentionLines" runat="server">
        <ItemTemplate>
            <div class="card mt-2">
                <div class="card-body card-body-sm">
                    <h5 class="card-title"><%# Eval("Item") %></h5>
                    <h6 class="card-subtitle"><%# Eval("Addressee") %></h6>
                    <div class="card-text"><%# Eval("DeliveryAddress") %></div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>

    <bbos:CompanyFooter ID="CompanyFooter" runat="server" />

</asp:Content>
