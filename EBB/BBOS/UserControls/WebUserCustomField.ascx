<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="WebUserCustomField.ascx.cs" Inherits="PRCo.BBOS.UI.Web.WebUserCustomField" %>


<tr class="" id="trRow" runat="server">
    <td class="p-2">
        <span id="tdSelect" runat="server" class="col-md-1 text-center mar_top_2" visible="false">
            <asp:Literal ID="litSelect" runat="server" />
        </span>
        <span id="tdLabel" runat="server" class="tw-col-span-3 col-md-3 text-left clr_blu text-nowrap">
            <% =_customField.prwucf_Label %>:
        </span>
    </td>

    <td class="p-2">
        <asp:Literal ID="litCustomField" runat="server" />
    </td>
</tr>
