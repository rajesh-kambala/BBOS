<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CompanyDetails.ascx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyDetails" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="bbos" TagName="BBScoreChart" Src="~/UserControls/BBScoreChart.ascx" %>

<asp:Label ID="hidCompanyID" Visible="false" runat="server" />
<asp:Label ID="hidRatingID" Visible="false" runat="server" />

<!-- Start Company Details -->
<div id="pCompanyDetails" runat="server" class="col4_box" >
    <div class="cmp_nme">
        <h4 class="blu_tab">
            <asp:Literal ID="litTitle" runat="server" />
        </h4>
    </div>

    <div class="tab_bdy dtl_tab">
        <div class="row bor_bottom nomargin pad10" id="trCreditWorthRating" runat="server">
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="clr_blu">
                    <asp:Literal runat="server" Text="<%$Resources:Global, CreditWorthRating%>" />:
                </p>
            </div>

            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="nopadding">
                    <asp:Label ID="lblCreditWorthRating" runat="server" CssClass="PopupLink" />
                    <asp:Label ID="lblCreditWorthRating2" runat="server" Visible="false" />
                </p>
            </div>
        </div>

        <div class="row bor_bottom nomargin pad10" id="trRatingNumeral" runat="server">
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="clr_blu">
                    <asp:Literal runat="server" Text="<%$Resources:Global, RatingKeyNumerals%>" />:
                </p>
            </div>

            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="nopadding">
                    <asp:Label ID="lblRatingNumeral" runat="server" CssClass="PopupLink" />
                    <asp:Label ID="lblRatingNumeral2" runat="server" Visible="false" />
                </p>
            </div>
        </div>

        <div class="row bor_bottom nomargin pad10" id="trPayIndicator" runat="server">
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="clr_blu">
                    <asp:Literal runat="server" Text="<%$Resources:Global, PayIndicator%>" />:
                </p>
            </div>

            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding form-inline">
                <p class="nopadding">
                    <asp:Label ID="lblPayIndicator" runat="server" CssClass="PopupLink"/>
                    <asp:Label ID="lblPayIndicator2" runat="server" Visible="false" />
                    &nbsp;
                    <asp:Image ID="WhatIsPayIndicator" CssClass="PopupLink" ImageUrl="~/images/info_sm.png" runat="server" style="vertical-align:middle;" ToolTip="<%$ Resources:Global, WhatIsThis %>" />

                    <asp:Panel ID="pnlPayIndicator" CssClass="Popup" Width="400" runat="server" />
                    <cc1:PopupControlExtender ID="pcePayIndicator" runat="server" TargetControlID="lblPayIndicator" PopupControlID="pnlPayIndicator" Position="bottom" />
                    <cc1:DynamicPopulateExtender ID="dpePayIndicator" runat="server" TargetControlID="pnlPayIndicator" PopulateTriggerControlID="lblPayIndicator"
                        ServiceMethod="GetPayIndicatorDefinition" ServicePath="AJAXHelper.asmx" CacheDynamicResults="true" />
                        
                    <asp:Panel ID="pnlWhatIsPayIndicator" style="display:none" CssClass="Popup" Width="400px" runat="server"><asp:Literal ID="ltWhatIsPayIndicator" Text="<%$ Resources:Global, WhatIsPayIndicator %>" runat="server" /></asp:Panel>
                    <cc1:PopupControlExtender ID="pceWhatIsPayIndicator" 
                            runat="server" 
                            TargetControlID="WhatIsPayIndicator" 
                            PopupControlID="pnlWhatIsPayIndicator"
                            Position="Bottom" /> 
                </p>
            </div>
        </div>

        <div class="row bor_bottom nomargin pad10" id="trPayReportCount" runat="server">
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="clr_blu">
                    <asp:Literal runat="server" Text="<%$Resources:Global, NumberofCurrentIndustryPayReports%>" />:
                </p>
            </div>

            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="nopadding">
                    <asp:Literal ID="litPayReportCount"  runat="server" />
                    <asp:HyperLink ID="hlPayReportCount" runat="server" CssClass="PopupLink" />
                </p>
            </div>
        </div>

        <div class="row bor_bottom nomargin pad10" id="trRating" runat="server">
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="clr_blu">
                    <asp:Literal Text="<%$ Resources:Global, Rating %>" ID="litRatingLabel" runat="server" />:
                </p>
            </div>
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding" runat="server">
                <asp:Panel ID="pnlRatingDate" runat="server" Visible="true">
                    <div class="dropdown my_dropd">
                        <p class="nopadding" data-bs-toggle="dropdown">
                            <asp:Label CssClass="PopupLink" ID="lblRating" runat="server" /> <%--1000M XXXX(40) AA--%>
                            <p style="height:2px">&nbsp;</p>
                            <asp:Label ID="lblRatingDate" runat="server" CssClass="smaller" />
                        </p>
                        <div class="dropdown-menu">
                            <div class="sch_result">
                            </div>
                        </div>
                    </div>
                </asp:Panel>
                <asp:Panel ID="pnlRatingDate2" runat="server" Visible="false">
                    <p class="nopadding">
                        <asp:Label ID="lblRatingDate2" runat="server" Text="Not Rated" />
                    </p>
                </asp:Panel>
            </div>
        </div>

        <asp:Panel ID="pnlRatingDefinition" Style="display: none; min-height:300px;" CssClass="Popup" Width="400" runat="server" />
        <cc1:PopupControlExtender ID="pceRating" runat="server" TargetControlID="lblRating" PopupControlID="pnlRatingDefinition" Position="bottom" />
        <cc1:DynamicPopulateExtender ID="pdeRating" runat="server" TargetControlID="pnlRatingDefinition" PopulateTriggerControlID="lblRating"
            ServiceMethod="GetRatingDefinitionCompanyDetails" ServicePath="AJAXHelper.asmx" CacheDynamicResults="true" />

        <asp:Panel ID="pnlRatingNumeral" Style="display: none" CssClass="Popup" Width="400" runat="server" />
        <cc1:PopupControlExtender ID="pceRatingNumeral" runat="server" TargetControlID="lblRatingNumeral" PopupControlID="pnlRatingNumeral" Position="bottom" />
        <cc1:DynamicPopulateExtender ID="dpeRatingNumeral" runat="server" TargetControlID="pnlRatingNumeral" PopulateTriggerControlID="lblRatingNumeral"
            ServiceMethod="GetRatingDefinitionNumerals" ServicePath="AJAXHelper.asmx" CacheDynamicResults="true" />

        <asp:Panel ID="pnlCreditWorthRating" Style="display: none" CssClass="Popup" Width="400" runat="server" />
        <cc1:PopupControlExtender ID="pceCreditWorthRating" runat="server" TargetControlID="lblCreditWorthRating" PopupControlID="pnlCreditWorthRating" Position="bottom" />
        <cc1:DynamicPopulateExtender ID="dpeCreditWorthRating" runat="server" TargetControlID="pnlCreditWorthRating" PopulateTriggerControlID="lblCreditWorthRating"
            ServiceMethod="GetRatingDefinitionCW" ServicePath="AJAXHelper.asmx" CacheDynamicResults="true" />

        <div class="row bor_bottom nomargin pad10" id="trBBScore" runat="server">
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="clr_blu"><% =Resources.Global.BlueBookScore %>:</p>
            </div>

            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="nopadding" data-bs-toggle="modal" data-bs-target="#pnlBBScoreChart1">
                    <asp:Literal ID="litBBScore" runat="server" />
                    <asp:Label ID="lblBBScore" runat="server" CssClass="PopupLink" />
                    <asp:Panel ID="pnlWhatIsBBScore" Style="display: none" CssClass="Popup" Width="400px" runat="server">
                        <asp:Image ID="WhatIsBBScore" CssClass="PopupLink" ImageUrl="~/en-us/images/info_icon.png" runat="server" Visible="false" Style="vertical-align: middle;" ToolTip="<%$ Resources:Global, WhatIsThis %>" />
                        <cc1:PopupControlExtender ID="pceWhatIsBBScore" runat="server" TargetControlID="WhatIsBBScore" PopupControlID="pnlWhatIsBBScore" Position="Bottom" />
                    </asp:Panel>
                </p>
            </div>
            <div class="col-md-12 col-sm-12 col-xs-12 col-p-6 nopadding" id="trBBScore2" runat="server">
                <div class="bb_scr text-center">
                    <asp:Image ID="imgBBScore" runat="server" data-bs-toggle="modal" data-bs-target="#pnlBBScoreChart1" />
                </div>
            </div>
        </div>

        <div class="row bor_bottom nomargin pad10" id="trClaimTable" runat="server">
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="clr_blu">
                    <asp:Literal ID="litClaimActivityHQ" runat="Server" /><% =Resources.Global.ClaimsActivityTableCAT.Replace(" (", "<br/>(") %>:
                </p>
            </div>

            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="nopadding">
                    <asp:HyperLink ID="hlClaimActivity" runat="server" Text="<%$Resources:Global, View %>" CssClass="PopupLink" />
                    <asp:HyperLink ID="hlClaimActivityNew" runat="server" ToolTip="<%$Resources:Global, NewClaimOpened %>" CssClass="PopupLink" />
                    <asp:HyperLink ID="hlClaimActivityMeritorious" runat="server" ToolTip="<%$Resources:Global, ClaimRecentlyFlaggedMeritorious %>" CssClass="PopupLink" />
                </p>
            </div>
        </div>

        <div class="row bor_bottom nomargin pad10" id="trARReports" runat="server">
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="clr_blu">
                    <%= Resources.Global.ARReports%>:
                </p>
            </div>

            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="nopadding">
                    <asp:HyperLink ID="hlARReports" runat="server" Text="<%$Resources:Global, View %>" CssClass="PopupLink" />
                </p>
            </div>
        </div>

        <div class="row bor_bottom nomargin pad10" id="trIndustry" runat="server">
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="clr_blu"><asp:Literal runat="server" Text="<%$Resources:Global, Industry%>" />:</p>
            </div>

            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="nopadding">
                    <asp:Literal ID="litIndustry" runat="server" />
                </p>
            </div>
        </div>

        <div class="row bor_bottom nomargin pad10" id="trType" runat="server">
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="clr_blu"><asp:Literal runat="server" Text="<%$Resources:Global, Type%>" />:</p>
            </div>

            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="nopadding">
                    <asp:Literal ID="litType" runat="server" />
                </p>
            </div>
        </div>

        <div class="row bor_bottom nomargin pad10" id="trStatus" runat="server">
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="clr_blu"><asp:Literal runat="server" Text="<%$Resources:Global, Status%>" />:</p>
            </div>

            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="nopadding">
                    <asp:Literal ID="litStatus" runat="server" />
                </p>
            </div>
        </div>

        <div class="row bor_bottom nomargin pad10" id="trPhone" runat="server">
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="clr_blu"><asp:Literal runat="server" Text="<%$Resources:Global, PhoneCamelCase%>" />:</p>
            </div>

            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="nopadding">
                    <asp:Literal ID="litPhone" runat="server" />
                </p>
            </div>
        </div>

        <div class="row bor_bottom nomargin pad10" id="trFax" runat="server">
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="clr_blu">FAX:</p>
            </div>

            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="nopadding">
                    <asp:Literal ID="litFax" runat="server" />
                </p>
            </div>
        </div>

        <div class="row bor_bottom nomargin pad10" id="pnlBusinessStart" runat="server">
            <div class="col-md-7 col-sm-7 col-xs-12 col-p-7 nopadding">
                <p class="clr_blu">
                    <asp:Literal ID="litBusinessStartDateStateTitle" runat="server" Text="<%$Resources:Global, BusinessDateState%>" />:</p>
            </div>

            <div class="col-md-5 col-sm-5 col-xs-12 col-p-5 nopadding">
                <p class="nopadding">
                    <asp:Literal ID="litBusinessStartDateState" runat="server" />
                </p>
            </div>
        </div>

        <div class="row bor_bottom nomargin pad10" id="trEmailAddress" runat="server">
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="clr_blu"><asp:Literal runat="server" Text="<%$Resources:Global, EmailAddress%>" />:</p>
            </div>

            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="nopadding">
                    <asp:HyperLink ID="hlEmail" runat="server" CssClass="PopupLink" />
                </p>
            </div>
        </div>

        <div class="row bor_bottom nomargin pad10" id="trWebSite" runat="server">
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="clr_blu"><asp:Literal runat="server" Text="<%$Resources:Global, WebSite%>" />:</p>
            </div>
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="nopadding">
                    <asp:HyperLink ID="hlWebsite" Target="_blank" runat="server" CssClass="PopupLink" />
                </p>
            </div>
        </div>

        <div class="row bor_bottom nomargin pad10" id="trSocialMedia" runat="server">
            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <p class="clr_blu"><asp:Literal runat="server" Text="<%$Resources:Global, SocialMedia%>" />:</p>
            </div>

            <div class="col-md-6 col-sm-6 col-xs-12 col-p-6 nopadding">
                <asp:Literal ID="litSocialMedia" runat="server" />
            </div>
        </div>
    </div>
</div>
<!-- End Company Details Header -->

<!-- Modal -->
<bbos:BBScoreChart id="ucBBScoreChart" runat="server" panelIndex="1" />
<!-- Modal END -->