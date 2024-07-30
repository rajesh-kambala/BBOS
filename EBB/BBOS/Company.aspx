<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="Company.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Company" Title="Blue Book Services" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="Sidebar" Src="UserControls/Sidebar.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyHero" Src="UserControls/CompanyHero.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyBio" Src="UserControls/CompanyBio.ascx" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeaderMeister" Src="UserControls/CompanyDetailsHeaderMeister.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PinnedNote2" Src="UserControls/PinnedNote2.ascx" %>
<%@ Register TagPrefix="bbos" TagName="BBScoreChart" Src="~/UserControls/BBScoreChart.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyListing" Src="UserControls/CompanyListing.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PerformanceIndicators" Src="UserControls/PerformanceIndicators.ascx" %>
<%@ Register TagPrefix="bbos" TagName="NewsArticles" Src="UserControls/NewsArticles.ascx" %>
<%@ Register TagPrefix="bbos" TagName="LocalSource" Src="UserControls/LocalSource.ascx" %>
<%@ Register TagPrefix="bbos" TagName="TradeAssociation" Src="UserControls/TradeAssociation.ascx" %>
<%@ Register TagPrefix="bbos" TagName="Classifications" Src="UserControls/Classifications.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CommoditiesList" Src="UserControls/CommoditiesList.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PrintHeader" Src="UserControls/PrintHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CustomData" Src="UserControls/CustomData.ascx" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Import Namespace="PRCo.EBB.BusinessObjects" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="contentMain" ContentPlaceHolderID="contentMain" runat="server">
    <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
    <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" Visible="false" />
</asp:Content>

<asp:Content ID="contentLeftSidebar" ContentPlaceHolderID="contentLeftSidebar" runat="server">
    <!-- Left nav bar  -->
    <bbos:Sidebar id="ucSidebar" runat="server" />
    <!-- Main  -->
    <main class="main-content tw-flex tw-flex-col tw-gap-y-4" id="company-main-content">
        <bbos:PrintHeader id="ucNewPrinterHeader" runat="server" Title='<% $Resources:Global, CompanyProfile %>' />
        <bbos:CompanyHero id="ucCompanyHero" runat="server" />
        <bbos:CompanyBio id="ucCompanyBio" runat="server" />
        <bbos:CompanyDetailsHeaderMeister ID="ucCompanyDetailsHeaderMeister" runat="server" />
        <p class="page-heading"><%= Resources.Global.CompanyProfile %></p>
        <section class="company-overview">
            <div class="tw-col-span-1 tw-flex tw-flex-col tw-gap-4 md:tw-col-span-8">
                <!-- Pinned notes -->
                <bbos:PinnedNote2 ID="ucPinnedNote" runat="server" />

                <!-- Premium Listing Info -->
                <bbos:CompanyListing ID="ucCompanyListing" runat="server" Format="2" />
            </div>
            <div class="tw-col-span-1 tw-flex tw-flex-col tw-gap-4 tw-self-start md:tw-col-span-4">
                <!-- Company Metrics -->
                <asp:Label ID="hidRatingID" Visible="false" runat="server" />

                <div class="bbs-card">
                    <div class="bbs-card-body no-padding">
                        <div class="tw-p-4 tw-flex tw-flex-col tw-gap-3" id="trCreditScore" runat="server">
                            <div class="tw-flex tw-items-center">
                                <h5 class="tw-flex-grow"><%=Resources.Global.BlueBookCreditScore %></h5>
                                <button
                                    type="button"
                                    tabindex="0"
                                    class="bbsButton bbsButton-tertiary small"
                                    role="button"
                                    data-bs-toggle="popover"
                                    data-bs-title="<%=Resources.Global.CreditScore %>"
                                    data-bs-trigger="focus"
                                    data-bs-custom-class="help-popover"
                                    data-bs-html="true"
                                    data-bs-content="<%=Resources.Global.CreditScorePopover %>">
                                    <span class="msicon notranslate">help</span>
                                </button>
                            </div>
                            
                            <p class="tw-text-xl tw-font-semibold tw-mb-2 tw-hidden" >
                                <asp:Literal ID="litCreditScore" runat="server" />
                                <asp:Label ID="lblCreditScore" runat="server" />
                            </p>
                                
                            <chart-slider 
                                min="500"
                                max="1000"
                                stops="6"
                                href="#performance_indicator_blueBookCreditScore"
                                current_value="<%=litCreditScore.Text %>"
                                begin_label="<%=Resources.Global.HighRisk %>"
                                end_label="<%=Resources.Global.LowRisk %>">
                            </chart-slider>
                                    
                            <div class="tw-flex tw-items-center" id="btnViewBBScoreHistory" runat="server">
                                <button
                                    class="bbsButton bbsButton-secondary small"
                                    type="button"
                                    data-bs-toggle="modal"
                                    data-bs-target="#pnlBBScoreChart1">
                                    <span class="msicon notranslate">history</span>
                                    <span class="tw-text-xs">
                                        <%=Resources.Global.SinceUC %>
                                        <asp:Literal ID="litCreditScoreDate" runat="server" />
                                    </span>
                                </button>
                            </div>
                            
                        </div>
                        <hr class="no-margin" />
                        <div class="tw-p-4">
                            <div class="tw-flex tw-items-center">
                                <h5 class="tw-flex-grow">
                                    <asp:Literal Text="<%$ Resources:Global, BlueBookRating %>" ID="litRatingLabel" runat="server" /></h5>
                                <button
                                    type="button"
                                    tabindex="0"
                                    class="bbsButton bbsButton-tertiary small"
                                    role="button"
                                    data-bs-toggle="popover"
                                    data-bs-title="<%=Resources.Global.BlueBookRating %>"
                                    data-bs-trigger="focus"
                                    data-bs-custom-class="help-popover"
                                    data-bs-html="true"
                                    data-bs-content="<%=Resources.Global.RatingPopover %>">
                                    <span class="msicon notranslate">help</span>
                                </button>
                            </div>
                            <asp:Panel ID="pnlRatingDate" runat="server" Visible="true" CssClass="tw-flex tw-gap-2 tw-flex-col">
                                <a href="#performance_indicator_blueBookRating" class="tw-text-xl tw-font-semibold">
                                    <asp:Label ID="lblRating" runat="server" />
                                </a>
                                <div class="tw-flex tw-items-center">
                                    <button id="btnRatingHistory2" runat="server"
                                        class="bbsButton bbsButton-secondary small"
                                        type="button"
                                        onclick="PopulateRatingHistory();">
                                        <span class="msicon notranslate">history</span>
                                        <span class="tw-text-xs">
                                            <%=Resources.Global.SinceUC %>
                                            <asp:Literal ID="litRatingDate" runat="server" />
                                        </span>
                                    </button>

                                    <span class="tw-flex-grow"></span>
                                    <button type="button" class="bbsButton bbsButton-secondary small" id="btnSubmitTES" runat="server" onclick="return ShowRateModalPopup()">
                                        <span><%=Resources.Global.Rate %></span>
                                    </button>
                                </div>
                            </asp:Panel>
                            <asp:Panel ID="pnlRatingDate2" runat="server" Visible="false">
                                <p class="nopadding">
                                    <asp:Label ID="lblRatingDate2" runat="server" Text="Not Rated" />
                                </p>
                            </asp:Panel>
                        </div>
                    </div>
                </div>

                <!-- Modal -->
                <bbos:BBScoreChart id="ucBBScoreChart" runat="server" panelIndex="1" />
                <!-- Modal END -->

                <!-- Company Map -->
                <div class="bbs-card" id="divMap" runat="server" visible="false">
                    <h5 class="tw-mb-2">
                        <span class="msicon notranslate">location_on</span> <%=Resources.Global.Map %>
                    </h5>
                    <div class="bbs-card-body no-padding">
                        <iframe
                            id="ifMap" runat="server"
                            height="200"
                            style="border: 0"
                            class="tw-m-auto"
                            allowfullscreen=""
                            loading="lazy"
                            referrerpolicy="no-referrer-when-downgrade"></iframe>
                        <p class="text-base tw-p-2 tw-font-semibold tw-text-text-secondary">
                            <asp:Literal ID="litMapAddress" runat="server" />
                        </p>
                    </div>
                </div>
            </div>
        </section>

        <bbos:PerformanceIndicators ID="ucPerformanceIndicators" runat="server" Visible="true" Hidden="true" />

        <section class="company-performance">
            <div class="bbs-card">
                <h5 class="tw-mb-2"><%=Resources.Global.PerformanceBreakdown %></h5>
                <div class="bbs-card-body no-padding" style="overflow-x:auto">
                    <table class="table">
                        <thead>
                            <tr>
                                <th scope="col"><%=Resources.Global.Indicator %></th>
                                <th scope="col" style="width: 33%; min-width: 300px"><%=Resources.Global.Value %></th>
                                <th scope="col" style="width: 33%; min-width: 300px"><%=Resources.Global.Insights %>
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- Blue Book Credit Score -->
                            <tr id="performance_indicator_blueBookCreditScore">
                                <td>
                                    <card-title
                                        title="<%=Resources.Global.BlueBookCreditScore %>"
                                        caption="<%=Resources.Global.BlueBookCreditScoreCaption %>" />
                                </td>
                                <td>
                                    <chart-slider
                                        min="500"
                                        max="1000"
                                        stops="6"
                                        current_value="<%=litCreditScore.Text %>"
                                        begin_label="<%=Resources.Global.HighRisk %>"
                                        end_label="<%=Resources.Global.LowRisk %>">
                                    </chart-slider>
                                    <p class="tw-flex-grow tw-text-text-tertiary">
                                        <span class="text-xxs"><%=GetCreditScoreDate() != "" ? Resources.Global.LastUpdated : "" %></span>
                                        <span class="tw-text-xs"><%=GetCreditScoreDate() %></span>
                                    </p>
                                </td>
                                <td>
                                    <div class="tw-flex tw-flex-col tw-gap-2" id="divInsight" runat="server" >
                                        <h5><%=GetOcd().szBBScoreRisk %></h5>
                                        <p class="tw-text-sm">
                                            <%=GetOcd().szBBScoreInsight %>
                                        </p>
                                        <button id="btnBBScoreHistoryInsight" runat="server"
                                            class="bbsButton bbsButton-secondary small full-width"
                                            type="button"
                                            data-bs-toggle="modal"
                                            data-bs-target="#pnlBBScoreChart1">
                                            <span class="msicon notranslate">history</span>
                                            <span><%=Resources.Global.SeeHistory %></span>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                            <!-- Total Rating -->
                            <tr id="performance_indicator_blueBookRating">
                                <td><h5><%=Resources.Global.BlueBookRating %></h5></td>
                                <td  style="width: 33%; min-width: 300px"><%=GetOcd().szRatingLine %></td>
                                <td style="width: 33%; min-width: 300px">
                                    <button
                                        class="bbsButton bbsButton-secondary small full-width"
                                        type="button"
                                        onclick="PopulateRatingHistory();"
                                             id="btnRatingHistory"
                                             runat="server">
                                        <span class="msicon notranslate">history</span>
                                        <span><%=Resources.Global.SeeHistory %></span>
                                    </button>
                                </td>
                            </tr>
                            <!-- Rating Breakdown -->
                            <tr>
                                 <td colspan="3" >
                                     <p class="caption"><%=Resources.Global.Rating %> Breakdown</p>
                                     <div class="tw-border tw-border-border tw-rounded tw-mt-4">
                                        <table >
                                            <tbody style="vertical-align: top;">
                                                <!-- Credit worth estimate -->
                                                <tr>
                                                    <td>
                                                        <card-title
                                                            title="<%=Resources.Global.CreditWorthEstimate %>"
                                                            caption="<%=Resources.Global.CreditWorthEstimateCaption %>" />
                                                    </td>
                                                    <td style="width: 33%; min-width: 300px">
                                                        <span class="tw-font-semibold"><%=GetOcd().szCreditWorthRating %></span> 
                                                        <%=GetOcd().szCreditWorthRating != "" ? "&#8212;" : ""  %>
                                                        <span class="tw-text-sm"><%=GetOcd().szCreditWorthRatingDescription %></span>
                                                    </td>
                                                    <td style="width: 33%; min-width: 300px">
                                                        <span class="tw-font-semibold"><%=GetOcd().szCreditWorthRating %></span> 
                                                        <%=GetOcd().szCreditWorthRating != "" ? "&#8212;" : ""  %>
                                                        <span class="tw-text-sm"><%=GetOcd().szCreditWorthRatingInsight %></span>
                                                    </td>
                                                </tr>

                                                <!-- "X" Rating -->
                                                <tr>
                                                    <td>
                                                        <card-title
                                                            title="<%=Resources.Global.XRating %>"
                                                            caption="<%=Resources.Global.XRatingCaption %>" />
                                                    </td>
                                                    <td>
                                                        <chart-box value="<%=GetOcd().szPRIN_Name %>"></chart-box>
                                                        <br />
                                                        <span class="tw-font-semibold"><%=GetOcd().szPRIN_Name.Replace("X", "") %></span>
                                                        <span class="tw-text-sm"><%= GetOcd().szRatingMeaning.Length > 0 ? " - " + GetOcd().szRatingMeaning  : "" %></span>
                                                    </td>
                                                    <td>
                                                        <div class="tw-flex tw-flex-col tw-gap-2">
                                                            <h5><%=GetOcd().szRatingDescription %></h5>
                                                            <p class="tw-text-sm">
                                                                <%= GetOcd().szRatingInsight %>
                                                            </p>
                                                        </div>
                                                    </td>
                                                </tr>

                                                <!-- Pay Description -->
                                                <tr>
                                                    <td>
                                                        <card-title
                                                            title="<%=Resources.Global.PayDescription %>"
                                                            caption="<%=Resources.Global.PayDescriptionCaption %>"Average Number of Days for Payment Rating" />
                                                    </td>
                                                    <td>
                                                        <chart-box value="<%=GetOcd().szPRPY_Name %>"></chart-box>
                                                        <br />
                                                        <span class="tw-font-semibold"><%= GetOcd().szPayDescriptionMeaning.Length > 0 ? GetOcd().szPRPY_Name : ""%></span>
                                                        <span class="tw-text-sm"><%= GetOcd().szPayDescriptionMeaning.Length > 0 ?  " - " + GetOcd().szPayDescriptionMeaning : "" %></span>
                                                    </td>
                                                    <td>
                                                        <div class="tw-flex tw-flex-col tw-gap-2">
                                                            <h5><%=GetOcd().szPayDescriptionRisk %></h5>
                                                            <p class="tw-text-sm"><%=GetOcd().szPayDescriptionInsight %></p>
                                                        </div>
                                                    </td>
                                                </tr>

                                                <!-- Key updates (Rating Numerals)-->
                                                <tr>
                                                    <td>
                                                        <card-title title="<%=Resources.Global.RatingNumeral %>"" />
                                                    </td>
                                                    <td>
                                                        <asp:Repeater ID="repKeyUpdates" runat="server">
                                                            <ItemTemplate>
                                                                <p>
                                                                    <span class="tw-font-semibold"><%#Eval("prrn_Name") %></span> &#8212; <span class="tw-text-sm"><%#Eval("prrn_Desc") %></span>
                                                                </p>
                                                            </ItemTemplate>
                                                        </asp:Repeater>
                                                    </td>
                                                    <td>
                                                        <div class="tw-flex tw-flex-col tw-gap-2">
                                                            <asp:Repeater ID="repKeyUpdatesInsight" runat="server">
                                                                <ItemTemplate>
                                                                    <p>
                                                                        <span class="tw-font-semibold"><%#Eval("prrn_Name") %></span> &#8212; <span class="tw-text-sm"><%#Eval("prrn_Insight") %></span>
                                                                    </p>
                                                                </ItemTemplate>
                                                            </asp:Repeater>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                     </div>
                                 </td>
                            </tr>
                             <!-- Trade Activity Summary -->
                             <tr>
                                 <td>
                                     <card-title
                                         title="<%=Resources.Global.TradeActivitySummary %>"
                                         caption="<%=Resources.Global.TradeActivitySummaryCaption %>" />
                                 </td>
                                 <td>
                                     <chart-slider
                                         min="1"
                                         max="4"
                                         stops="7"
                                         stops_labels="X,XX,XXX,XXXX"
                                         current_value="<%=GetOcd().decAveIntegrity==0 ? "N/A" : GetOcd().decAveIntegrity.ToString("0.00") %>"
                                         begin_label="Poor"
                                         end_label="Excellent"
                                         value_decimal="true">
                                     </chart-slider>
                                 </td>
                                 <td>
                                     <div class="tw-flex tw-flex-col tw-gap-2" id="divTradeReportRiskInsight" runat="server">
                                         <h5><%=GetOcd().szTradeReportRisk %></h5>
                                         <p class="tw-text-sm"><%=GetOcd().szTradeReportInsight %></p>
                                         <button
                                             class="bbsButton bbsButton-secondary small full-width"
                                             type="button"
                                             onclick="PopulateTradeActivitySummary()"
                                             id="btnSeeTradeActivityHistory" runat="server">

                                             <span class="msicon notranslate">history</span>
                                             <span><%=Resources.Global.SeeHistory %></span>
                                         </button>
                                     </div>
                                 </td>
                             </tr>

                        </tbody>
                    </table>
                </div>
            </div>
        </section>

        <section class="company-performance" id="pnlProgressLazy" runat="server">
            <div class="bbs-card">
                <h5 class="tw-mb-2"></h5>
                <asp:UpdateProgress ID="updProgressNews" runat="server" AssociatedUpdatePanelID="upnlNews">
                    <ProgressTemplate>
                        <div class="tw-flex tw-flex-col tw-items-center tw-text-center">
                            <asp:Image ID="imgLoadingNews" runat="server" ImageUrl="images/BBOSProgress.gif" />
                        </div>
                    </ProgressTemplate>
                </asp:UpdateProgress>
            </div>
        </section>

        <asp:UpdatePanel ID="upnlNews" runat="server" UpdateMode="Conditional" OnPreRender="upnlNews_PreRender" >
            <ContentTemplate>
                <section class="company-updates-news tw-hidden">
                    <div class="bbs-card">
                        <h5 class="tw-mb-2"><%=Resources.Global.UpdatesAndNews %></h5>
                        <div class="tw-flex tw-flex-col tw-gap-4">
                            <!-- News -->
                            <bbos:NewsArticles ID="ucNewsArticles" runat="server" Visible="true" DisplayAbstract="false" Format="2" />
                        </div>
                    </div>
                </section>
            </ContentTemplate>
        </asp:UpdatePanel>

        <asp:UpdatePanel ID="upnlBusinessDetails" runat="server" UpdateMode="Conditional" OnPreRender="upnlBusinessDetails_PreRender">
            <ContentTemplate>
                <section class="company-business-details tw-hidden">
                    <div class="bbs-card no-padding">
                        <h5 class="tw-mb-2" id="businessdetails"><%=Resources.Global.BusinessDetails %></h5>
                        <div class="bbs-card-body accordion accordion-flush no-padding">
                            <%--Key Business Information--%>
                            <div class="accordion-item">
                                <div class="accordion-header">
                                    <button
                                        class="accordion-button"
                                        type="button"
                                        data-bs-toggle="collapse"
                                        data-bs-target="#flush_otherInfo"
                                        aria-expanded="false"
                                        aria-controls="flush_otherInfo">
                                        <h5><%=Resources.Global.KeyBusinessInformation %></h5>
                                    </button>
                                </div>
                                <div
                                    id="flush_otherInfo"
                                    class="accordion-collapse collapse show tw-p-4">
                                    <div class="bbs-card-body no-padding">
                                        <table
                                            class="table"
                                            cellspacing="0"
                                            sortasc="False"
                                            sortfield="prcl_Abbreviation"
                                            id="contentMain_ucotherInfo_gvotherInfo"
                                            style="border-collapse: collapse">
                                            <tbody>
                                                <tr>
                                                    <td>
                                                        <asp:Literal ID="litBusinessStartDateStateTitle" runat="server" Text="<%$Resources:Global, BusinessDateState%>" /></td>
                                                    <td>
                                                        <asp:Literal ID="litBusinessStartDateState" runat="server" /></td>
                                                </tr>

                                                <tr>
                                                    <td><%=Resources.Global.Bank %></td>
                                                    <td>
                                                        <asp:Literal ID="litBank" runat="server" /></td>
                                                </tr>

                                                <%--<tr><td>Number of Employees (self-reported)</td><td>11-50</td></tr>--%>

                                                <asp:Repeater ID="repVolume" runat="server">
                                                    <ItemTemplate>
                                                        <tr>
                                                            <td>
                                                                <p><%=Resources.Global.Volume %></p>
                                                                <p class="tw-text-xs tw-text-text-secondary"><%=Resources.Global.VolumeText2 %></p>
                                                            </td>
                                                            <td><%#DataBinder.Eval(Container.DataItem, "VolumeName") %></td>
                                                        </tr>
                                                    </ItemTemplate>
                                                </asp:Repeater>

                                                <tr>
                                                    <td>
                                                        <p><%=Resources.Global.ARReports%></p>
                                                        <p class="tw-text-xs tw-text-text-secondary"><%=Resources.Global.ARReportsCaption %></p>
                                                    </td>
                                                    <td><%=GetOcd().szAR_TotalNumCompanies %></td>
                                                </tr>
                                                <tr>
                                                    <td><%=Resources.Global.HandlesRejectedShipments %></td>
                                                    <td><%=GetOcd().szSalvageDistressedProduce=="Y"?Resources.Global.Yes : Resources.Global.NotApplicableAbbr %></td>
                                                </tr>

                                                <tr>
                                                    <td>
                                                        <p><%=Resources.Global.CertifiedOrganic%></p>
                                                        <p class="tw-text-xs tw-text-text-secondary"><%=Resources.Global.SelfReportedNotBBSValidated %></p>
                                                    </td>
                                                    <td><%=GetOcd().bIsCertifiedOrganic?Resources.Global.Yes : Resources.Global.NotApplicableAbbr %></td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <p><%=Resources.Global.FoodSafetyCertified%></p>
                                                        <p class="tw-text-xs tw-text-text-secondary"><%=Resources.Global.SelfReportedNotBBSValidated %></p>
                                                    </td>
                                                    <td><%=GetOcd().bIsFoodSafetyCertified?Resources.Global.Yes : Resources.Global.NotApplicableAbbr %></td>
                                                </tr>

                                                <asp:Repeater ID="repLicenses" runat="server" OnItemDataBound="repLicenses_ItemDataBound">
                                                    <ItemTemplate>
                                                        <tr>
                                                            <td><asp:Literal ID="litName" runat="server" /></td>
                                                            <td><asp:Literal ID="litLicense" runat="server" /></td>
                                                        </tr>
                                                    </ItemTemplate>
                                                </asp:Repeater>

                                                <tr>
                                                    <td><%=Resources.Global.BranchesAndAffiliations %></td>
                                                    <td><%=GetBranchCount() %>&nbsp;<%=Resources.Global.Branches %> / <%=GetAffiliationCount() %>&nbsp;<%=Resources.Global.Affiliations %></td>
                                                </tr>
                                                <tr>
                                                    <td><%=Resources.Global.Industry %></td>
                                                    <td><%=GetOcd().szIndustryTypeName %></td>
                                                </tr>
                                                <tr>
                                                    <td><%=Resources.Global.Type %></td>
                                                    <td><%=GetCompanyTypeName(GetOcd().szCompanyType)%></td>
                                                </tr>
                                                <tr>
                                                    <td><%=Resources.Global.Status %></td>
                                                    <td><%=GetOcd().szListingStatusName %></td>
                                                </tr>
                                                <tr>
                                                    <td><%=Resources.Global.Phone2 %></td>
                                                    <td><%=GetOcd().szPhone %></td>
                                                </tr>
                                                <tr>
                                                    <td>FAX</td>
                                                    <td><%=GetOcd().szFax %></td>
                                                </tr>
                                                <tr>
                                                    <td><%=Resources.Global.EmailAddress %></td>
                                                    <td><%=GetOcd().szEmailAddress %></td>
                                                </tr>
                                                <tr>
                                                    <td><%=Resources.Global.SocialMedia %></td>
                                                    <td><asp:Literal ID="litSocialMedia" runat="server" /></td>
                                                </tr>
                                            </tbody>
                                            <tfoot></tfoot>
                                        </table>
                                    </div>
                                </div>
                            </div>
                            <%--Local Source--%>
                            <bbos:LocalSource ID="ucLocalSource" runat="server" Format="2" />
                            <%--Trade Association--%>
                            <bbos:TradeAssociation ID="ucTradeAssociation" runat="server" Visible="true" Format="2" />
                            <%--Classifications--%>
                            <bbos:Classifications ID="ucClassifications" runat="server" Format="2" />
                            <%--Commodities--%>
                            <bbos:CommoditiesList ID="ucCommoditiesList" runat="server" Format="2" />
                            <%--Custom Data--%>
                            <bbos:CustomData ID="ucCustomData" runat="server" Visible="true" Format="2" HideEditCustomDataButton="true" />
                        </div>
                    </div>
                </section>
            </ContentTemplate>
        </asp:UpdatePanel>
        <br />
        <br />
        <br />
    </main>

    <script src="Scripts/chart_slider.js"></script>
    <script src="Scripts/chart_box.js"></script>
    <script src="Scripts/card_title.js"></script>
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">
    <script language="javascript" type="text/javascript">
        function pageLoad(sender, e) {
            if (!e.get_isPartialLoad()) {
                __doPostBack('<%= upnlBusinessDetails.ClientID %>', '<%=Company.RUN_ONCE_SCRIPT_IDENTIFIER%>');
                $('.company-business-details').removeClass('tw-hidden');
                __doPostBack('<%= upnlNews.ClientID %>', '<%=Company.RUN_ONCE_SCRIPT_IDENTIFIER%>');
                $('.company-updates-news').removeClass('tw-hidden');
            }
            else
            {
                showPanels();
            }
        }

        function showPanels()
        {
            $('.company-business-details').removeClass('tw-hidden');
            $('.company-updates-news').removeClass('tw-hidden');
        }
    </script>
</asp:Content>
