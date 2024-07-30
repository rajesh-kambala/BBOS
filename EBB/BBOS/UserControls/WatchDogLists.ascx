<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="WatchDogLists.ascx.cs" Inherits="PRCo.BBOS.UI.Web.WatchDogLists" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Panel ID="Categories" CssClass="small_horizontal_box" runat="server">
    <div class="col4_box">
        <div class="cmp_nme">
            <h4 class="blu_tab"><% = Resources.Global.WatchdogLists %></h4>
        </div>
        <div class="tab_bdy pad5">
            <table class="table table-hover table-striped">
                <tr>
                    <asp:Repeater ID="repCategories" runat="server">
                        <ItemTemplate>
                            <% _categoryIndex++; %>
                            <% =GetBeginColumnSeparator(_categoryCount, 2, _categoryIndex)%>
                            <tr>
                                <td><%# PageControlBaseCommon.GetCategoryIcon(Eval("prwucl_CategoryIcon"), Eval("prwucl_Name"))%> <%# Eval("prwucl_Name") %></td>
                            </tr>
                            <% =GetEndColumnSeparator(_categoryCount, 2, _categoryIndex)%>
                            <% _iRepeaterRowCount++; %>
                        </ItemTemplate>
                    </asp:Repeater>
                </tr>
            </table>

            <asp:Panel ID="pnlCategoryRemove" runat="server" CssClass="Popup" align="center" Style="display: none">
                <iframe id="ifrmCategoryRemove" frameborder="0" style="width: 600px; height: 450px; overflow-y: hidden;" scrolling="yes" runat="server"></iframe>
            </asp:Panel>

            <cc1:ModalPopupExtender ID="mdeCategoryRemove" runat="server"
                TargetControlID="btnCategoryRemove"
                PopupControlID="pnlCategoryRemove"
                BackgroundCssClass="modalBackground" />

            <div class="row pad10 bb_service">
                <div class="col-md-6 col-sm-12 search_crit">
                    <asp:LinkButton CssClass="btn MediumButton gray_btn" ID="btnCategoryAddTo" runat="server" OnClick="btnAddToWatchdogOnClick">
                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnAddToWatchdogList%>" />
                    </asp:LinkButton>

                    <asp:LinkButton CssClass="btn MediumButton gray_btn" runat="server" PostBackUrl="~/UserListList.aspx">
                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, ManageWatchdogGroups %>" />
                    </asp:LinkButton>
                </div>
                <div class="col-md-6 col-sm-12 search_crit">
                    <span style="display:none;"><asp:LinkButton id="btnCategoryRemove" Text="<%$ Resources:Global, RemoveFromWatchdogGroup %>" runat="server" /></span>
                    <asp:LinkButton CssClass="btn MediumButton gray_btn" ID="btnCategoryRemove2" runat="server" OnClick="btnRemoveCategory_Click">
                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, RemoveFromWatchdogGroup %>" />
                    </asp:LinkButton>
                </div>
            </div>
        </div>
    </div>
</asp:Panel>
