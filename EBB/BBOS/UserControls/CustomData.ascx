<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CustomData.ascx.cs" Inherits="PRCo.BBOS.UI.Web.CustomData" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Panel ID="pnlCustomFields1" CssClass="small_horizontal_box" runat="server">
    <div class="col4_box">
        <div class="cmp_nme">
            <h4 class="blu_tab"><% = Resources.Global.CustomData %></h4>
        </div>
        <div class="tab_bdy pad5">
            <table class="table">
                <asp:Repeater ID="repCustomFields1" runat="server" OnItemCreated="RepCustomFields_ItemCreated">
                    <ItemTemplate>
                        <asp:PlaceHolder ID="phCustomField" runat="server" />
                    </ItemTemplate>
                </asp:Repeater>
            </table>

            <div class="row pad10 bb_service">
                <div class="col-md-6 col-sm-12 search_crit">
                    <asp:LinkButton CssClass="btn MediumButton gray_btn" ID="btnCustomFieldEdit1" runat="server" OnClick="btnEditCustomFields_Click">
                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnEditCustomData %>" />
                    </asp:LinkButton>
                </div>
                <div class="col-md-6 col-sm-12 search_crit">
                    <asp:LinkButton CssClass="btn MediumButton gray_btn" ID="btnCustomFieldManage1" runat="server" PostBackUrl="~/CustomFieldList.aspx">
                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, btnManageCustomData %>" />
                    </asp:LinkButton>
                </div>
            </div>
        </div>
    </div>
</asp:Panel>

<asp:Panel ID="pnlCustomFields2" CssClass="accordion-item" runat="server">
    <div class="accordion-header">
        <button
            class="accordion-button collapsed"
            type="button"
            data-bs-toggle="collapse"
            data-bs-target="#flush_CustomData"
            aria-expanded="false"
            aria-controls="flush_CustomData">
            <h5><% = Resources.Global.CustomData %></h5>
        </button>
    </div>
    <div
        id="flush_CustomData"
        class="accordion-collapse collapse tw-p-4">
        <div class="bbs-card-body no-padding">
            <table
                class="table"
                cellspacing="0"
                sortasc="False"
                sortfield="prcl_Abbreviation"
                id="contentMain_ucCustomData_gvCustomData"
                style="border-collapse: collapse">
                    <tbody>
                        <asp:Repeater ID="repCustomFields2" runat="server" OnItemCreated="RepCustomFields_ItemCreated">
                            <ItemTemplate>
                                <tr>
                                    <td><asp:Literal ID="litCustomFieldLabel" runat="server" /></td>
                                    <td><asp:Literal ID="litCustomFieldValue" runat="server" /></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>

                        <tr>
                            <td colspan="2">
                                <div class="tw-flex tw-gap-2">
                                    <button
                                        type="button"
                                        class="bbsButton bbsButton-secondary full-width"
                                        id="btnCustomFieldEdit2" runat="server"
                                        onserverclick="btnCustomFieldEdit2_ServerClick">
                                        <span class="msicon notranslate">edit</span>
                                        <span class="text-label"><%=Resources.Global.btnEditCustomData %></span>
                                    </button>
                                    <button
                                        type="button"
                                        class="bbsButton bbsButton-secondary full-width"
                                        id="btnCustomFieldManage2" runat="server" 
                                        onserverclick="btnCustomFieldManage2_ServerClick">
                                            <span class="msicon notranslate">tune</span>
                                            <span class="text-label"><%=Resources.Global.btnManageCustomData %></span>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
            </table>
        </div>
    </div>
</asp:Panel>