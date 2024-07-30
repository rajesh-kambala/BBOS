<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="LSSPurchase.aspx.cs" Inherits="PRCo.BBOS.UI.Web.LSSPurchase" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Label ID="hidTriggerPage" Visible="false" runat="server" />

    <div class="row nomargin">
        <div class="col-md-12">
            <%=Resources.Global.LSSPurchaseTopText %>
        </div>
    </div>

    <div class="row nomargin">
        <div class="col-md-12">
            <asp:GridView ID="gvPersonAccess"
                AllowSorting="true"
                Width="100%"
                CellSpacing="2"
                runat="server"
                AutoGenerateColumns="false"
                CssClass="sch_result table table-striped table-hover fa-border"
                GridLines="none" 
                OnSorting="gvPersonAccess_Sorting"
                OnRowDataBound="gvPersonAccess_RowDataBound">

                <Columns>
                    <asp:TemplateField HeaderText="<%$ Resources:Global, Select %>" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center">
                        <ItemTemplate>
                            <input type="checkbox" name="cbPRWebUserID" id="cbPRWebUserID" runat="server" value='<%# Eval("prwu_WebUserID") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="<%$ Resources:Global, PersonName %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left" SortExpression="pers_LastName">
                        <ItemTemplate>
                            <asp:Literal ID="litPersonName" runat="server" Text='<%# UIUtils.GetString(Eval("PersonName"))%>' />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left" DataField="CityStateCountryShort" SortExpression="CityStateCountryShort" />
                    <asp:BoundField HeaderText="<%$ Resources:Global, AccessLevel %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left" DataField="prwu_AccessLevel" SortExpression="prwu_AccessLevel" />
                    <asp:TemplateField HeaderText="<%$ Resources:Global, HasLocalSourceAccess %>" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center" SortExpression="HasLSSAccess">
                        <ItemTemplate>
                            <asp:Literal ID="litHasLSSAccess" runat="server" Text='<%# UIUtils.GetStringFromBool(Eval("HasLSSAccess"))%>' />
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
