<%@ Page Title="" Language="C#" MasterPageFile="~/BBSI.master" AutoEventWireup="true" CodeBehind="CompanyPerson.aspx.cs" Inherits="BBOSMobileSales.CompanyPerson" %>

<%@ Register TagPrefix="bbos" TagName="CompanyHeader" Src="UserControls/CompanyHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyFooter" Src="UserControls/CompanyFooter.ascx" %>


<asp:Content ID="Content1" ContentPlaceHolderID="Content1" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Content2" runat="server">
    <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
    <bbos:CompanyHeader ID="ucCompanyHeader" runat="server" />

    <asp:Repeater ID="repPerson" runat="server" OnItemDataBound="repPerson_ItemDataBound">
        <ItemTemplate>
            <div class="card mt-2">
                <div class="card-body card-body-sm">
                    <h5 class="card-title"><%# Eval("Name") %></h5>
                    <h6 class="card-subtitle text-muted"><%# Eval("Title") %></h6>
                    <asp:PlaceHolder ID="phEmail" runat="server">
                        <a class="card-link" href="mailto:<%# Eval("Email") %>"><%# Eval("Email") %></a>
                    </asp:PlaceHolder>

                    <asp:PlaceHolder ID="phLicLevel" runat="server">
                        <div class="row card-text">
                            <div class="col-5">
                                <label>Lic Level:</label>
                            </div>
                            <div class="col-7"><%# Eval("Lic Level") %></div>

                            <div class="col-5">
                                <label>Last Access:</label>
                            </div>
                            <div class="col-7"><%# Eval("Last Access") %></div>

                            <div class="col-5">
                                <label>Pgs Viewed:</label>
                            </div>
                            <div class="col-7"><%# Eval("BBOS Page Cnt") %></div>
                        </div>
                    </asp:PlaceHolder>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>

    <bbos:CompanyFooter ID="CompanyFooter" runat="server" />
</asp:Content>