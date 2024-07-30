<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="ExpressUpdatesPurchase.aspx.cs" Inherits="PRCo.BBOS.UI.Web.ExpressUpdatesPurchase" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Label ID="hidTriggerPage" Visible="false" runat="server" />

    <div class="row nomargin">
        <div class="col-md-12">
            <%=Resources.Global.ExpressUpdatesPurchaseTopText %>
        </div>
    </div>

    <div class="row nomargin">
        <div class="col-md-12">
            <asp:GridView ID="gvExpressUpdates"
                AllowSorting="false"
                Width="100%"
                CellSpacing="2"
                runat="server"
                AutoGenerateColumns="false"
                CssClass="sch_result table table-striped table-hover fa-border"
                GridLines="none">

                <Columns>
                    <asp:TemplateField HeaderText="<%$ Resources:Global, Select %>" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center">
                        <ItemTemplate>
                            <input type="radio" name="rbProductID" value="21" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="<%$ Resources:Global, Product %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left">
                        <ItemTemplate>
                            <asp:Literal ID="litDesc" runat="server" Text='<%# UIUtils.GetString(Eval("ProductName"))%>' />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="<%$ Resources:Global, Price %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left">
                        <ItemTemplate>
                            <asp:Literal ID="litPrice" runat="server" Text='<%# UIUtils.GetString(Eval("Price", "{0:c}")) + " " + Eval("Annually")%>' />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="<%$ Resources:Global, HasExpressUpdates %>" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center" >
                        <ItemTemplate>
                            <asp:Literal ID="litHasExpressUpdates" runat="server" Text='<%# UIUtils.GetStringFromBool(Eval("HasExpressUpdates"))%>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <div class="row nomargin_lr">
        <div class="col-md-12">
            <asp:LinkButton ID="btnPurchase" runat="server" CssClass="btn gray_btn" OnClick="btnPurchaseOnClick">
			    <i class="fa fa-caret-right" aria-hidden="true"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnPurchase %>" />
            </asp:LinkButton>
            <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancelOnClick">
			    <i class="fa fa-caret-right" aria-hidden="true"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, btnCancel %>" />
            </asp:LinkButton>
        </div>
    </div>
</asp:Content>
