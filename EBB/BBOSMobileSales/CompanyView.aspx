<%@ Page Title="" Language="C#" MasterPageFile="~/BBSI.master" AutoEventWireup="true" CodeBehind="CompanyView.aspx.cs" Inherits="BBOSMobileSales.CompanyView" %>

<%@ Register TagPrefix="bbos" TagName="CompanyHeader" Src="UserControls/CompanyHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyFooter" Src="UserControls/CompanyFooter.ascx" %>


<asp:Content ID="Content1" ContentPlaceHolderID="Content1" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="Content2" runat="server">
    <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
    <bbos:CompanyHeader ID="ucCompanyHeader" runat="server" />

    <div class="card">
        <div class="card-body card-body-sm">
            <h5 class="card-title mt-0">Company Summary</h5>

            <div class="row " id="summary">

                <div class="col-12 dataItem">
                    <label>Current M Level:</label><br />
                    <asp:Label ID="CurrentMLevel" runat="server" />
                </div>

                <div class="col-12 dataItem">
                    <label>Member Since:</label><br />
                    <asp:Label ID="MemberSince" runat="server" />
                </div>

                <div class="col-12 dataItem">
                    <label>Current Rating:</label><br />
                    <asp:Label ID="CurrentRating" runat="server" />
                </div>

                <div class="col-12 dataItem">
                    <label>Trip Code:</label><br />
                    <asp:Label ID="TripCode" runat="server" />
                </div>
            </div>
        </div>
    </div>

    <div class="card mt-2">
        <div class="card-body card-body-sm">
            <h5 class="card-title mt-0">Preferred Phones</h5>
            <div class="row" id="phone">
                <asp:Repeater ID="repPreferredPhones" runat="server">
                    <ItemTemplate>
                        <div class="col-12 dataItem">
                            <label><%# Eval("phon_PRDescription") %>:</label><br />
                            <a href="tel:<%# Eval("Num") %>"><%# Eval("Num") %></a>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <div class="card mt-2">
        <div class="card-body card-body-sm">
            <h5 class="card-title mt-0">Addresses</h5>

            <div class="row" id="address">
                <asp:Repeater ID="repAddresses" runat="server">
                    <ItemTemplate>
                        <div class="col-12 dataItem">
                            <label><%# Eval("AddressType") %>:</label><br />
                            <%# (Eval("addr_Address1") == DBNull.Value) ? "" : string.Concat(Eval("addr_Address1"),"<br />")%>
                            <%# (Eval("addr_Address2") == DBNull.Value) ? "" : string.Concat(Eval("addr_Address2"),"<br />")%>
                            <%# Eval("CityStateCountryShort") %>&nbsp;<%# Eval("addr_PostCode") %><br />
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <div class="card mt-2">
        <div class="card-body card-body-sm">
            <h5 class="card-title mt-0">Listing/Rating Facts</h5>
            <div class="row" id="rating">
                <asp:Repeater ID="repRatingFacts" runat="server">
                    <ItemTemplate>
                        <div class="col-12 dataItem">
                            <label><%#Eval("FactName") %>:</label><br />
                            <%#Eval("FactValue") %>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <bbos:CompanyFooter ID="CompanyFooter" runat="server" />
</asp:Content>