<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="BusReportPurchase.aspx.cs" Inherits="PRCo.BBOS.UI.Web.BusReportPurchase" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Label ID="hidTriggerPage" Visible="false" runat="server" />

    <div class="row">
        <div class="col-md-12">
            <asp:Label ID="litMsg" runat="server" Text="<%$ Resources:Global, ServiceUnitPurchaseMsg %>" />
        </div>
    </div>

    <div class="row">
        <div class="col-md-8">
            <asp:GridView ID="gvProducts"
                AllowSorting="false"
                runat="server"
                AutoGenerateColumns="false"
                CssClass="sch_result table table-striped table-hover tab_bdy"
                GridLines="none">

                <Columns>
                    <asp:TemplateField HeaderText="<%$ Resources:Global, Select %>" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center">
                        <ItemTemplate>
                            <input type="radio" name="rbProductID" value="<%# Eval("prod_ProductID") %>" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField HeaderText="<%$ Resources:Global, BusinessReports %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left" DataField="prod_PRServiceUnits" DataFormatString="{0:N0}" HtmlEncode="false" />

                    <asp:TemplateField HeaderStyle-CssClass="text-nowrap" HeaderText="<%$ Resources:Global, ExpirationDate %>">
                        <ItemTemplate>
                            <%# Resources.Global.Oneyearfromdateofpurchase %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField HeaderText="<%$ Resources:Global, Price %>" HeaderStyle-CssClass="text-nowrap" DataField="pric_Price" DataFormatString="${0:N0}" HtmlEncode="false" />
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <div class="row mb-3">
        <div class="col-md-12">
            <asp:LinkButton ID="btnPurchase" runat="server" CssClass="btn gray_btn" OnClick="btnPurchaseOnClick">
				    <i class="fa fa-caret-right" aria-hidden="true"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Purchase %>" />
            </asp:LinkButton>
            <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancelOnClick">
				    <i class="fa fa-caret-right" aria-hidden="true"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnCancel %>" />
            </asp:LinkButton>
        </div>
    </div>
</asp:Content>
