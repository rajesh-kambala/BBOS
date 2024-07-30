<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ErrorDisplay.ascx.cs" Inherits="PRCo.BBOS.UI.Web.ErrorDisplay" %>

<style>
    p {
        font-size: 11pt !important;
    }
</style>

<div class="row nomargin panels_box">
    <div class="panel panel-primary col-md-8 offset-md-2 col-xs-12">
        <div class="panel-heading">
            <h4 class="blu_tab">
                <asp:Label ID="lblHeader" runat="server" Text="<%$ Resources:Global, SystemErrorOccurred %>" />
            </h4>
        </div>
        <div class="row panel-body nomargin pad10">
            <asp:Literal ID="lblMsg" runat="server" />

            <asp:Panel ID="pnlButtons" runat="server" Style="margin-top: 15px">
                <a href="javascript:location.href='Default.aspx';" class="btn btnWidthStd gray_btn"><%=Resources.Global.Home %></a>
                <a href="javascript:history.go(-1);" class="btn btnWidthStd gray_btn"><%=Resources.Global.PreviousPage %></a>
            </asp:Panel>
        </div>
    </div>
</div>
