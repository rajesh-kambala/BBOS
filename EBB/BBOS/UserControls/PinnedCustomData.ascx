<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PinnedCustomData.ascx.cs" Inherits="PRCo.BBOS.UI.Web.UserControls.PinnedCustomData" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<div class="panel panel-primary">
    <div class="panel-heading">
        <h4 class="blu_tab">Pinned Custom Data</h4>
    </div>

    <div class="row panel-body nomargin pad10" id="trCustomFields" visible="true" runat="server">
        <div class="col-md-12 mar_top mar_bot">
            <asp:Repeater OnItemCreated="RepCustomFields_ItemCreated" ID="repCustomFields" runat="server">
                <ItemTemplate>
                    <asp:PlaceHolder ID="phCustomField" runat="server" />
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

    <div class="row panel-body nomargin pad10" id="trCustomFieldEmpty" visible="false" runat="server">
        <div class="col-md-12 mar_top mar_bot">
            <span style="font-style: italic;">No Custom Data has been pinned.</span>

            <div class="text-left" style="margin-bottom:10px;">
                <asp:LinkButton CssClass="btn btnWidthStd gray_btn" runat="server" PostBackUrl="~/CustomFieldList.aspx">
	                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="Manage Custom Data" />
                </asp:LinkButton>
            </div>
        </div>
    </div>
</div>
