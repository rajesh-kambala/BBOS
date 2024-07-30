<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="QuickFind.ascx.cs" Inherits="PRCo.BBOS.UI.Web.QuickFind" EnableViewState="false" %>

<!-- begin quick find -->
<asp:Panel runat="server" DefaultButton="btnQuickFind" CssClass="tw-w-full">
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

    <div>
        <asp:TextBox ID="txtQuickFindDummy" runat="server" Style="position: absolute; display: none;" />
        <asp:TextBox ID="txtQuickFind" CssClass="pill full-width" runat="server" autocomplete="off" placeholder="<%$ Resources:Global,  QuickfindPlaceholder %>" />
        <asp:ImageButton ID="btnQuickFind" OnClick="btnQuickFindOnClick" CssClass="d-none" AlternateText="<%$ Resources:Global, SearchWithQuickFind %>" runat="server" />
        <div id="pnlQuickFindAutoComplete" style="z-index: 5000; width: 100%!important"></div>
    </div>
</asp:Panel>
<!-- end quick find -->
