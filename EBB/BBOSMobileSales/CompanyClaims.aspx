<%@ Page Title="" Language="C#" MasterPageFile="~/BBSI.master" AutoEventWireup="true" CodeBehind="CompanyClaims.aspx.cs" Inherits="BBOSMobileSales.CompanyClaims" %>

<%@ Register TagPrefix="bbos" TagName="CompanyHeader" Src="UserControls/CompanyHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyFooter" Src="UserControls/CompanyFooter.ascx" %>


<asp:Content ID="Content1" ContentPlaceHolderID="Content1" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Content2" runat="server">
    <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
    <bbos:CompanyHeader ID="ucCompanyHeader" runat="server" />

    <asp:Repeater ID="repClaims" runat="server">
        <ItemTemplate>
            <div class="card mt-2">
                <div class="card-body">
                    <h5 class="card-title">Dispute over whether transportation services complied with the sales agreement and/or resulting damages.</h5>
                    <h6 class="card-subtitle text-muted"><%# Eval("prss_CreatedDate", "{0:MM/dd/yyyy}") %></h6>

                    <div class="row card-text">
                        <div class="col-3">
                            <label>Status:</label></div>
                        <div class="col-9"><%# Eval("Status") %></div>

                        <div class="col-3">
                            <label>Amount:</label></div>
                        <div class="col-9"><%# Eval("prss_InitialAmountOwed", "{0:C}") %></div>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>

    <bbos:CompanyFooter ID="CompanyFooter" runat="server" />
</asp:Content>
