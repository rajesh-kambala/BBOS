<%@ Page Title="" Language="C#" MasterPageFile="~/BBSI.master" AutoEventWireup="true" CodeBehind="CompanyInteractions.aspx.cs" Inherits="BBOSMobileSales.CompanyInteractions" %>

<%@ Register TagPrefix="bbos" TagName="CompanyHeader" Src="UserControls/CompanyHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyFooter" Src="UserControls/CompanyFooter.ascx" %>


<asp:Content ID="Content1" ContentPlaceHolderID="Content1" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Content2" runat="server">
    <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
    <bbos:CompanyHeader ID="ucCompanyHeader" runat="server" />

    <asp:Repeater ID="repInteractions" runat="server">
        <ItemTemplate>
            <div class="card mt-2">
                <div class="card-body">
                    <h5 class="card-title"><%# Eval("comm_subject") %></h5>
                    <h6 class="card-subtitle text-muted"><%# Eval("Comm_DateTime") %></h6>

                    <div class="row card-text">
                        <div class="col-3">
                            <label>User:</label>
                        </div>
                        <div class="col-9"><%#Eval("user") %></div>
                    </div>
                    <div class="card-text">
                        <p>
                            <%# Eval("Comm_Note") %>
                        </p>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>

    <bbos:CompanyFooter ID="CompanyFooter" runat="server" />
</asp:Content>
