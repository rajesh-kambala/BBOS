<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="Downloads.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Downloads" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="BlueBookScoreDistribution" Src="Widgets/BlueBookScoreDistribution.ascx" %>
<%@ Register TagPrefix="bbos" TagName="IndustryPayTrends" Src="Widgets/IndustryPayTrends.ascx" %>
<%@ Register TagPrefix="bbos" TagName="IndustryMetricsSnapshot" Src="Widgets/IndustryMetricsSnapshot.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row">
        <div class="col-sm-6 vertical-align-top">
            <span class="Title"><% =Resources.Global.BBOSMobile%></span><br />
            <asp:Literal ID="litBBOSMobile" runat="server" /><br />
            <br />

            <asp:Panel ID="pnlProduceAppLinks" runat="server" Visible="false" Style="vertical-align: top;">
                <a href="https://apps.apple.com/us/app/bbos-mobile-produce/id1023371285?itsct=apps_box_badge&amp;itscg=30200" target="_blank" style="display: inline-block; overflow: hidden; border-radius: 13px; height: 40px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&amp;releaseDate=1439337600&h=261541d50d8a1a945c327ca19f0123aa" alt="Download on the App Store" style="border-radius: 13px; height: 40px;"></a>
                <a href="https://play.google.com/store/apps/details?id=com.bbos.BBOSMobile.android" target="_blank" style="display: inline-block; overflow: hidden">
                    <img alt="Get it on Google Play" width="135" height="40" src="https://www.producebluebook.com/wp-content/uploads/2015/09/Google-Play-Icon.jpg" />
                </a>
            </asp:Panel>

            <asp:Panel ID="pnlLumberAppLinks" runat="server" Visible="false" Style="vertical-align: top;">
                <a href="https://apps.apple.com/us/app/bbos-mobile-lumber/id1023463520?itsct=apps_box_badge&amp;itscg=30200" target=”_blank” style="display: inline-block; overflow: hidden; border-radius: 13px; height: 40px;"><img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&amp;releaseDate=1443830400&h=bef0650d4d669cc3141f8379a8de856d" alt="Download on the App Store" style="border-radius: 13px; height: 40px;"></a>
                <a href="https://play.google.com/store/apps/details?id=com.bbos.BBOSMobile.Lumber.android" target="_blank" style="display: inline-block; overflow: hidden">
                    <img alt="Get it on Google Play" width="135" height="40" src="https://www.producebluebook.com/wp-content/uploads/2015/09/Google-Play-Icon.jpg" />
                </a>
            </asp:Panel>
            <br />
        </div>
        <div class="col-sm-6 vertical-align-top">
            <span class="Title"><% =Resources.Global.CreditSheetDownloads%></span><br />
            <asp:Literal ID="litCompanyUpdates" runat="server" /><br />
            <br />
            <asp:LinkButton ID="hlCompanyUpdates" runat="server" CssClass="btn gray_btn">
		        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, DownloadNow %>" />
            </asp:LinkButton>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-6 vertical-align-top">
            <span class="Title">
                <asp:Literal ID="litDownloadshortcut" runat="server" />
            </span>
            <br />
            <% =Resources.Global.ApplicationShortcutMsg%><br />
            <br />
            <asp:LinkButton ID="btnDownloadShortcut" runat="server" CssClass="btn gray_btn" OnClick="btnDownloadShortcutOnClick">
		        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Open %>" />
            </asp:LinkButton>
        </div>
        <div class="col-sm-6 vertical-align-top" runat="server" id="tdUSDAMarket">
            <span class="Title"><% =Resources.Global.USDAMarketNewsFVPrices%></span><br />
            <asp:Literal ID="litUSDAMarketNewsFVPricesDesc" runat="server" Text="<%$Resources:Global, USDAMarketNewsFVPricesDesc%>" /><br />
            <br />
            <asp:HyperLink ID="btnUSDAMarketNews" runat="server" CssClass="btn gray_btn" NavigateUrl="https://mymarketnews.ams.usda.gov/" Target="_blank">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, GetUSDAMarketNewsPrices %>" />
            </asp:HyperLink>
        </div>
    </div>

    <div class="row mar_top">
        <div class="col-sm-6 vertical-align-top" id="tdWebServices" runat="server">
            <span class="Title"><% =Resources.Global.BBOSWebServices%></span><br />
            <% =Resources.Global.BBOSWebServicesMsg%><br />
            <br />
            <asp:HyperLink ID="hlWebServices" runat="server" CssClass="btn gray_btn" Target="_blank">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Open %>" />
            </asp:HyperLink>
        </div>

        <asp:Panel ID="pnlPACADRCViolators" runat="server">
            <div class="col-sm-6 vertical-align-top mar_top25">
                <span class="Title"><%=Resources.Global.PACADRCViolatorsReportTitle%></span>
                <br />
                <%=Resources.Global.PACADRCViolatorsReportDescription%><br />
                <br />
                <asp:LinkButton ID="btnPACADRCViolatorsReport" runat="server" CssClass="btn gray_btn" OnClick="btnPACADRCViolatorsReport_Click">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, GetPACADRCViolatorsReport %>" />
                </asp:LinkButton>
            </div>
        </asp:Panel>
    </div>

    <div class="row mar_top">
        <div class="col-sm-6 vertical-align-top">
            <span class="Title"><%=Resources.Global.BankruptcyReportTitle%></span>
            <br />
            <%=Resources.Global.BankruptcyReportDescription%><br />
            <br />
            <asp:Linkbutton ID="btnBankruptcyReport" runat="server" CssClass="btn gray_btn" OnClick="btnBankruptcyReportOnClick">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, GetBankruptcyReport %>" />
            </asp:Linkbutton>
        </div>
        <div class="col-sm-6 vertical-align-top">
            <span class="Title"><% =Resources.Global.BlueBookScoreDistribution%></span><br />
            <asp:Literal ID="litBlueBookScoreDistribution" runat="server" Text="<%$Resources:Global, BlueBookScoreDistributionDesc%>" /><br />
            <br />
            <asp:LinkButton ID="btnBlueBookScoreDistribution" runat="server" CssClass="btn gray_btn">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, GetBBScoreDistributionReport %>" />
            </asp:LinkButton>
        </div>
        
    </div>

    <div class="row mar_top">
        <div class="col-sm-6 vertical-align-top">
            <span class="Title"><% =Resources.Global.IndustryAccountsReceivable%></span><br />
            <asp:Literal ID="litIndustryAccountsReceivableDesc" runat="server" Text="<%$Resources:Global,  IndustryAccountsReceivableDesc%>" /><br />
            <br />
            <asp:LinkButton ID="btnIndustryAccountsReceivable" runat="server" CssClass="btn gray_btn">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, GetIndustryARReport %>" />
            </asp:LinkButton>
        </div>
        
    </div>

    <div class="row mar_top">
        <div class="col-sm-6 vertical-align-top">
            <span class="Title"><% =Resources.Global.IndustryMetricsSnapshot%></span><br />
            <asp:Literal ID="litIndustryMetricsSnapshotDesc" runat="server" Text="<%$Resources:Global, IndustryMetricsSnapshotDesc%>" /><br />
            <br />
            <asp:LinkButton ID="btnIndustryMetricsSnapshot" runat="server" CssClass="btn gray_btn">
                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, GetIndustryMetricsReport %>" />
            </asp:LinkButton>
        </div>

    </div>
    
    <!--Widget Popups -->
    <asp:Panel ID="WidgetIndustryAccountsReceivable" Width="600px" runat="server" Style="display: none; max-height: 600px;" CssClass="Popup">
        <bbos:IndustryPayTrends ID="widIndustryAccountsReceivable" runat="server" ChangeWidgetsLinkVisible="false" />
        <asp:LinkButton ID="Close1" runat="server" CssClass="btn gray_btn">
            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Close %>" />
        </asp:LinkButton>
    </asp:Panel>

    <cc1:ModalPopupExtender ID="ModalPopupExtender1" runat="server"
        TargetControlID="btnIndustryAccountsReceivable"
        PopupControlID="WidgetIndustryAccountsReceivable"
        OkControlID="Close1"
        BackgroundCssClass="modalBackground" 
    />

    <asp:Panel ID="WidgetBlueBookScoreDistribution" Width="600px" runat="server" Style="display: none; max-height: 600px;" CssClass="Popup">
        <bbos:BlueBookScoreDistribution ID="widBlueBookScoreDistribution" runat="server" ChangeWidgetsLinkVisible="false" />
        <asp:LinkButton ID="Close2" runat="server" CssClass="btn gray_btn">
            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Close %>" />
        </asp:LinkButton>
    </asp:Panel>

    <cc1:ModalPopupExtender ID="ModalPopupExtender2" runat="server"
        TargetControlID="btnBlueBookScoreDistribution"
        PopupControlID="WidgetBlueBookScoreDistribution"
        OkControlID="Close2"
        BackgroundCssClass="modalBackground" 
    />

    <asp:Panel ID="WidgetIndustryMetricsSnapshot" Width="600px" runat="server" Style="display: none; max-height: 600px;" CssClass="Popup">
        <bbos:IndustryMetricsSnapshot ID="widIndustryMetricsSnapshot" runat="server" ChangeWidgetsLinkVisible="false" />
        <asp:LinkButton ID="Close3" runat="server" CssClass="btn gray_btn">
            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, Close %>" />
        </asp:LinkButton>
    </asp:Panel>

    <cc1:ModalPopupExtender ID="ModalPopupExtender3" runat="server"
        TargetControlID="btnIndustryMetricsSnapshot"
        PopupControlID="WidgetIndustryMetricsSnapshot"
        OkControlID="Close3"
        BackgroundCssClass="modalBackground" 
    />
    
</asp:Content>
