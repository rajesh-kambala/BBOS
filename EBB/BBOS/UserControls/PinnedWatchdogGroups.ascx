<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PinnedWatchdogGroups.ascx.cs" Inherits="PRCo.BBOS.UI.Web.UserControls.PinnedWatchdogGroups" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<div class="panel panel-primary">
    <div class="panel-heading">
        <h4 class="blu_tab">Pinned Watchdog Groups</h4>
    </div>

    <div class="row panel-body nomargin pad10" id="trCategory" visible="true" runat="server">
        <div class="col-md-12 mar_top mar_bot">
            <asp:Repeater ID="repCategories" runat="server">
                <ItemTemplate>
                    <tr>
                        <td><%# PageControlBaseCommon.GetCategoryIcon(Eval("prwucl_CategoryIcon"), Eval("prwucl_Name"))%> <%# Eval("prwucl_Name") %></td>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

    <div class="row panel-body nomargin pad10" id="trCategoryEmpty" visible="false" runat="server">
        <div class="col-md-12 mar_top mar_bot">
            <span style="font-style: italic;">No Watchdog Groups have been pinned.</span>

            <div class="text-left" style="margin-bottom:10px;">
                <asp:LinkButton CssClass="btn btnWidthStd gray_btn" runat="server" PostBackUrl="~/UserListList.aspx">
	                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="Manage Watchdog Groups" />
                </asp:LinkButton>
            </div>
        </div>
    </div>
</div>
