<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Advertisement.ascx.cs" Inherits="PRCo.EBB.UI.Web.Advertisement" EnableViewState="false" %>

<!-- Begin Advertisment -->

<div class="advertising_box">
<h2><a href="<% =PRCo.EBB.UI.Web.Configuration.AdvertiserMediaKitURL %>" target="_blank">ADVERTISEMENT</a></h2>
<table style="width:220px;margin-left:auto;margin-right:auto;border:none;" cellpadding="0" cellspacing="0">
<tr>
    <td  style="width:220px;text-align:left;vertical-align:top;">
        <table  style="width:220px;border:none;" cellspacing="0" cellpadding="0">
        <tr id="trAdTitleRow" runat="server">
            <td></td>
        </tr>
        <tr>
            <td style="text-align:center;vertical-align:top;background-color:#FFFFFF;">
                <table style="width:220px;border:none;"  cellpadding="0" cellspacing="0">
                <tr>
                    <td style="text-align:center;vertical-align:top;">
                        <table  style="width:218px;border:none;"  cellpadding="6" cellspacing="0">
                        <asp:Literal ID="litAdvertisement" runat="server" />
                        </table>
                    </td>
                    <td id="tdBodyRight" style="width:1px;text-align:right;vertical-align:top;background-color:#d4d5d5;" runat="server" visible="false"></td>
                </tr>
                <tr id="trBodyBottom" runat="server" visible="false">
                    <td style="vertical-align:top;background-color:#d4d5d5;" colspan="3"></td>
                </tr>
                </table>
            </td>
        </tr>
        </table>
    </td>
</tr>
</table>
</div>
<!-- End Advertisment -->