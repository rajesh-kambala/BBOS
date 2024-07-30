<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="PersonAccessList.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PersonAccessList" MaintainScrollPositionOnPostback="true" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row nomargin_lr">
        <div class="col-md-12 clr_blu">
            <asp:Literal ID="litHeaderMsg" runat="server" />
        </div>
    </div>

    
    <div class="row nomargin_lr mar_top tab_bdy">
        <div class="col-md-12">
            <div class="table-responsive">
                <asp:GridView ID="gvPersonAccess"
                    AllowSorting="true"
                    Width="100%"
                    CellSpacing="2"
                    runat="server"
                    AutoGenerateColumns="false"
                    CssClass="table table-striped table-hover"
                    GridLines="none"
                    OnSorting="GridView_Sorting"
                    OnRowDataBound="GridView_RowDataBound">

                    <Columns>
                        <asp:BoundField HeaderText="<%$ Resources:Global, PersonName %>" ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="vertical-align-top" DataField="PersonName" SortExpression="pers_LastName" />
                        <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="vertical-align-top" DataField="CityStateCountryShort" SortExpression="CityStateCountryShort" />

                        <asp:TemplateField ItemStyle-CssClass="text-center vertical-align-top" HeaderStyle-CssClass="text-center vertical-align-top" HeaderText="<%$ Resources:Global, BBOSPublish %>" SortExpression="peli_PREBBPublish">
                            <ItemTemplate>
                                <%# UIUtils.GetStringFromBool(Eval("peli_PREBBPublish"))%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField HeaderText="<%$ Resources:Global, LicensePasswordAssigned %>" ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="text-left vertical-align-top" DataField="prwu_AccessLevel" SortExpression="prwu_AccessLevel" />

                        <asp:TemplateField ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="text-left vertical-align-top" HeaderText="<%$ Resources:Global, CanSubmitTES %>" SortExpression="peli_PRSubmitTES">
                            <ItemTemplate>
                                <%# UIUtils.GetStringFromBool(Eval("peli_PRSubmitTES"))%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="text-left vertical-align-top" HeaderText="<%$ Resources:Global, CanModifyConnectionList %>" SortExpression="peli_PRUpdateCL">
                            <ItemTemplate>
                                <%# UIUtils.GetStringFromBool(Eval("peli_PRUpdateCL"))%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="text-left vertical-align-top" HeaderText="<%$ Resources:Global, CanUseBusinessReports %>" SortExpression="peli_PRUseServiceUnits">
                            <ItemTemplate>
                                <%# UIUtils.GetStringFromBool(Eval("peli_PRUseServiceUnits"))%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="text-left vertical-align-top" HeaderText="<%$ Resources:Global, CanUseSpecialServices %>" SortExpression="peli_PRUseSpecialServices">
                            <ItemTemplate>
                                <%# UIUtils.GetStringFromBool(Eval("peli_PRUseSpecialServices"))%>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="text-left vertical-align-top" HeaderText="<%$ Resources:Global, HasLocalSourceAccess %>" SortExpression="HasLSSAccess">
                            <ItemTemplate>
                                <%# UIUtils.GetStringFromBool(Eval("HasLSSAccess"))%>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-md-12">
            <asp:LinkButton ID="btnPurchase" runat="server" CssClass="btn SmallButton gray_btn" OnClick="btnDoneOnClick">
	            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnDone %>" />
            </asp:LinkButton>
        </div>
    </div>
</asp:Content>
