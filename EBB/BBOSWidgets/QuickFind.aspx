<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuickFind.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Widgets.QuickFind" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>BBSi Quick Find Widget</title>
    <script type="text/javascript" src="javascript/QuickFind.min.js"></script>
    <!--ListenLayer.com - Custom Forms Helper Script--> 
    <script>(function (w, d, s) { var f = d.getElementsByTagName(s)[0], j = d.createElement(s); j.async = true; j.src = 'https://assets.listenlayer.com/datalayercustomformhelper.min.js'; f.parentNode.insertBefore(j, f); })(window, document, 'script');</script>
</head>
<body>
    <form id="form1" runat="server" class="find-company">
    <asp:ScriptManager ID="ScriptManager1" runat="server"/>

    <asp:Panel ID="pnlQuickFind" runat="server" style="padding:0px;margin:0px;" EnableViewState="false">

    <asp:TextBox ID="txtQuickFindDummy" runat="server" style="position: absolute; visibility: hidden;" EnableViewState="false" />
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr id="trQuickFindHdr" runat="server">
        <td style="background-color:#2f3293"><asp:Image ID="imgQuickFindHdr" runat="server" AlternateText="" EnableViewState="false" /></td>
    </tr>

    <tr>    
        <td id="quickSearchBox">
            <asp:TextBox ID="txtQuickFind" CssClass="searchIcon" runat="server" autocomplete="off" EnableViewState="false" />
        </td>
    </tr>   
    <tr>
        <td>
            <asp:Panel class="bottomPanel" runat="server" ID="pnlBottom">
            Blue Book Services is the produce industry’s credit 
            and marketing authority. Search by company name above
            and link to vital information about the business. 
            (Members access the full credit rating)
            </asp:Panel>
        </td>
    </tr>
    </table>

    <cc1:AutoCompleteExtender ID="aceQuickFind" runat="server" 
        TargetControlID="txtQuickFind"
        ServiceMethod="GetQuickFindCompletionList"
        ServicePath=""
        CompletionInterval="100"
        MinimumPrefixLength="2"
        CompletionSetCount="30"
        CompletionListCssClass="AutoCompleteFlyout"
        CompletionListItemCssClass="AutoCompleteFlyoutItem"
        CompletionListHighlightedItemCssClass="AutoCompleteFlyoutHilightedItem"
        OnClientItemSelected="AutoCompleteSelected"
        OnClientPopulated="acePopulated"
        CompletionListElementID="pnlAutoComplete"
        DelimiterCharacters="|"
        EnableCaching="true"
        UseContextKey="true"
        FirstRowSelected="true" >
    </cc1:AutoCompleteExtender>
    
    <div id="pnlAutoComplete" style="z-index:5000;padding:2px;height:200px;"></div>

	<!-- Added by Patrick Johnson on 2/15/2019 to display an advertising banner when showBannerAd is passed as a parameter to this page -->
	<% if(Request["showBannerAd"] != null) {%>
	    <style>body #pnlAutoComplete {position: relative !important; margin-bottom: 40px !important;} #pnlQuickFind {width: 100% !important;}</style>
	    <script type="text/javascript" id="bbsiGetAdsWidget" src="javascript/GetAdsWidget.min.js"></script>
	    <div id="bannerAdCompanies" style="text-align: center; margin-top:20px;"></div>
	    <script type="text/javascript">
	        var licenseKey = "BBSIProduceAds";
            var pageName = "ProduceMarketingSite";
            var ad2 = new BBSiGetAdsWidget("bannerAdCompanies", licenseKey, pageName, 1, "PMSHPB");
	    </script>
	<% } %>

    <div id="Div1" style="padding:2px;height:200px;"></div>

    </asp:Panel>
    </form>
</body>
</html>
