<%@ Page Title="" Language="C#" MasterPageFile="~/BBSI.master" AutoEventWireup="true" CodeBehind="CompanyOpportunity.aspx.cs" Inherits="BBOSMobileSales.CompanyOpportunity" %>

<%@ Register TagPrefix="bbos" TagName="CompanyHeader" Src="UserControls/CompanyHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyFooter" Src="UserControls/CompanyFooter.ascx" %>


<asp:Content ID="Content1" ContentPlaceHolderID="Content1" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Content2" runat="server">
    <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
    <bbos:CompanyHeader ID="ucCompanyHeader" runat="server" />

    <asp:Repeater ID="repOpportunities" runat="server">
        <ItemTemplate>
            <div class="card mt-2">
                <div class="card-body">
                    <h5 class="card-title"><%# Eval("Type") %></h5>
                    <h6 class="card-subtitle text-muted"><%# Eval("Stat") %></h6>
                    <div class="row card-text">
                        <div class="col-5">
                            <label>User:</label></div>
                        <div class="col-7"><%# Eval("User") %></div>

                        <div class="col-5">
                            <label>Created:</label></div>
                        <div class="col-7"><%# Eval("DateCreated") %></div>

                        <div class="col-5">
                            <label>Forecast:</label></div>
                        <div class="col-7"><%# Eval("Forecast") %></div>

                        <div class="col-5">
                            <label>Subtype:</label></div>
                        <div class="col-7"><%# Eval("Subtype") %></div>

                        <div class="col-5">
                            <label>Target Date:</label></div>
                        <div class="col-7"><%# Eval("TargetDate") %></div>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>

    <bbos:CompanyFooter ID="CompanyFooter" runat="server" />
</asp:Content>
