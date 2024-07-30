<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="QuickFind.ascx.cs" Inherits="PRCo.BBOS.UI.Web.QuickFind" EnableViewState="false" %>

<ajaxToolkit:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server"
    TargetControlID="txtQuickFind"
    ServiceMethod="GetQuickFindCompletionList"
    ServicePath="AJAXHelper.asmx"
    CompletionInterval="100"
    MinimumPrefixLength="2"
    CompletionSetCount="30"
    CompletionListCssClass="AutoCompleteFlyout"
    CompletionListItemCssClass="AutoCompleteFlyoutItem"
    CompletionListHighlightedItemCssClass="AutoCompleteFlyoutHilightedItem"
    OnClientItemSelected="AutoCompleteSelected"
    OnClientPopulated="acePopulated"
    CompletionListElementID="pnlQuickFindAutoComplete"
    EnableCaching="True"
    FirstRowSelected="false">
</ajaxToolkit:AutoCompleteExtender>

<div class="search-box">
    <asp:TextBox ID="txtQuickFindDummy" runat="server" Style="position: absolute; display: none;" />
    <asp:TextBox ID="txtQuickFind" runat="server" CssClass="form-control" autocomplete="off" placeholder="<%$ Resources:Global,  QuickfindPlaceholder %>" />
    <asp:ImageButton Visible="false" ID="btnQuickFind" OnClick="btnQuickFindOnClick" AlternateText="<%$ Resources:Global, SearchWithQuickFind %>" runat="server" />
    <div id="pnlQuickFindAutoComplete" style="z-index: 5000; width: 100%!important"></div>
</div>