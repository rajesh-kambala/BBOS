<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CompanyDetailsHeader.ascx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyDetailsHeader" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>
<%@ Register TagPrefix="bbos" TagName="BBScoreChart" Src="~/UserControls/BBScoreChart.ascx" %>

<!-- Start Company Details Header -->
<div class="col4_box" id="pCompanyDetailsHeader">
    <style>
        img {
            min-width: 15px;
        }
    </style>
    <div class="cmp_nme">
        <h4 class="blu_tab">
            <asp:Literal ID="litTitle" runat="server" />
        </h4>
    </div>
    <div class="row panel-body nomargin tab_bdy pad10">
        <div class="col-md-10 col-sm-10 col-xs-10" id="divLeftCol" runat="server">
            <asp:Image ID="imgIcon" Visible="false" runat="server" />
            <asp:HyperLink ID="hlNote" Visible="false" runat="server" />
            <asp:HyperLink ID="hlCertified" Visible="false" runat="server" />
            <asp:HyperLink ID="hlChanged" Visible="false" runat="server" />
            <asp:Image ID="imgOnWatchdogList" Visible="false" runat="server" />
        </div>
        <div class="col-md-6 col-sm-6 col-xs-5" style="line-height: 1.2em;" id="DynCol1" runat="server">
            <p><% =Resources.Global.BBNumber %><asp:Literal ID="litBBID" runat="server" /></p>
            <p><asp:HyperLink ID="hlCompanyName" runat="server" CssClass="explicitlink" /></p>
            <p><asp:Literal ID="litCompanyName" runat="server" Visible="false" /></p>
            <p><asp:Literal ID="litLocation" runat="server" /></p>
            <p id="trRatingNumeral" runat="server">
                <span class="DetailsDataLabel"><% =Resources.Global.RatingKeyNumerals%>:</span>
                <span class="DetailsLabel"><asp:Literal ID="lblRatingNumeral" runat="server" /></span>
            </p>
            <p id="trPayIndicator" runat="server" class="text-nowrap">
                <span class="DetailsDataLabel"><% =Resources.Global.PayIndicator%>:</span>
                <span class="DetailsLabel"><asp:Literal ID="lblPayIndicator" runat="server" /></span>
            </p>
            <p id="trRating" runat="server" class="text-nowrap">
                <span class="DetailsDataLabel"><asp:Literal Text="<%$ Resources:Global, Rating %>" ID="litRatingLabel" runat="server" />:</span>
                <span class="DetailsLabel">
                    <asp:Label CssClass="PopupLink" ID="lblRating" runat="server" /> <%--1000M XXXX(40) AA--%>
                </span>
            </p>

            <asp:Panel ID="pnlRatingDefinition" Style="display: none; min-height:500px;" CssClass="Popup" Width="400" runat="server" />
            <cc1:PopupControlExtender ID="pceRating" runat="server" TargetControlID="lblRating" PopupControlID="pnlRatingDefinition" Position="bottom" />
            <cc1:DynamicPopulateExtender ID="pdeRating" runat="server" TargetControlID="pnlRatingDefinition" PopulateTriggerControlID="lblRating"
                ServiceMethod="GetRatingDefinitionCompanyDetailsHeader" ServicePath="AJAXHelper.asmx" CacheDynamicResults="true" />

            <p id="trBBScore" runat="server">
                <span class="DetailsDataLabel"><% =Resources.Global.BlueBookScore %>:</span>

                <span class="nopadding" data-bs-toggle="modal" data-bs-target="#pnlBBScoreChart2">
                    <asp:Literal ID="litBBScore" runat="server" />
                    <asp:Label ID="lblBBScore" runat="server" CssClass="PopupLink" data-bs-toggle="modal" data-bs-target="#pnlBBScoreChart2" />

                    <asp:Panel ID="pnlWhatIsBBScore" Style="display: none" CssClass="Popup" Width="400px" runat="server">
                        <asp:Image ID="WhatIsBBScore" CssClass="PopupLink" ImageUrl="~/en-us/images/info_icon.png" runat="server" Visible="false" Style="vertical-align: middle;" ToolTip="<%$ Resources:Global, WhatIsThis %>" />
                        <cc1:PopupControlExtender ID="pceWhatIsBBScore" runat="server" TargetControlID="WhatIsBBScore" PopupControlID="pnlWhatIsBBScore" Position="Bottom" />
                    </asp:Panel>
                </span>
            </p>

            <p id="trMessage" runat="server" class="text-center mar_top bold" visible="false">
                <asp:Label class="MsgHightlight" ID="litMessage" runat="server" /><br />
                <asp:LinkButton ID="btnCompanyUpdates" runat="server" CssClass="btn gray_btn" Visible="false" PostBackUrl="CompanyDetailsCompanyUpdates.aspx">
				    <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, SeeUpdatesForDetails %>" />
                </asp:LinkButton>
                    
            </p>

            <p id="trUnverified" visible="false" runat="server" class="text-center">
                <asp:Label ID="lbUnverified" CssClass="PopupLink2" Text="<%$ Resources:Global, ListingVerificationPending%>" runat="server" />
            </p>
        </div>
        <div class="col-md-5 col-sm-5 col-xs-5" id="DynCol2" runat="server">
            <div class="cmp_logo text-center" id="trTMFM" runat="server">
                <asp:Image ID="imgTMFM" runat="server" Visible="false" CssClass="seal" />
                <p>
                    <asp:Label ID="lblTMFMMsg" CssClass="annotation" runat="server" />
                </p>
            </div>
        </div>
    </div>
</div>

<div class="top_horizontal_box" style="text-align: left; margin-left: 0;">
    <asp:Panel ID="pnlUnverified" Style="display: none" CssClass="Popup" Width="400px" Height="200px" runat="server">
        <div class="popup_header">
            <button type="button" class="close" data-bs-dismiss="modal" onclick="document.getElementById('<%= pnlUnverified.ClientID %>').style.display='none';">&times;</button>
        </div>
        <div class="popup_content">
            <asp:Literal ID="ltUnverified" Text="<%$ Resources:Global, WhatIsLUV %>" runat="server" />
        </div>
    </asp:Panel>

    <cc1:PopupControlExtender ID="pceUnverified"
        runat="server"
        TargetControlID="lbUnverified"
        PopupControlID="pnlUnverified"
        Position="Bottom" />
</div>
<div class="clearfix"></div>
<!-- End Company Details Header -->

<!-- Modal -->
<bbos:BBScoreChart id="ucBBScoreChart" runat="server" panelIndex="2" />
<!-- Modal END -->
