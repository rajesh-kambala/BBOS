<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdvancedCompanySearch.aspx.cs" Inherits="PRCo.BBOS.UI.Web.AdvancedCompanySearch" MasterPageFile="BBOS.Master" EnableEventValidation="false" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Src="UserControls/AdvancedCompanySearchCriteriaControl.ascx" TagName="AdvancedCompanySearchCriteriaControl" TagPrefix="uc1" %>


<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
</asp:Content>

<asp:Content ID="contentMain" ContentPlaceHolderID="contentMain" runat="server">
    <asp:HiddenField ID="hidPostback" runat="server" />
    <asp:HiddenField ID="hidClearCriteria" runat="server" />

    <asp:HiddenField ID="hidSelectedStates" runat="server" />
    <asp:HiddenField ID="hidOtherCountries" runat="server" />
    <asp:HiddenField ID="hidTerminalMarkets" runat="server" />
    <asp:HiddenField ID="hidCommodities" runat="server" />
    <asp:HiddenField ID="hidAttributes" runat="server" />
    <asp:HiddenField ID="hidClassifications" runat="server" />

    <asp:Panel ID="pnlSearch" DefaultButton="btnSearch" runat="server" CssClass="tw-p-4">
        <div class="search-selection-container">
            <div class="search-form">
                <%--SECTION: Search Form--%>
                <div class="search-form">
                    <h2><asp:Literal ID="litHeader" runat="server" /></h2>
                    <div class="bbs-accordion">
                        <!-- Company Details -->
                        <asp:Panel ID="pnlCompanyDetailsForm" CssClass="bbs-accordion-item" runat="server">
                            <button
                                onclick="toggleAccordion(event); event.preventDefault();"
                                class="bbs-accordion-header">
                                <div>
                                    <span class="msicon notranslate expand-icon">expand_more</span>
                                </div>
                                <div class="label">
                                    <span class="text-label"><%=Resources.Global.CompanyDetails %></span>
                                    <span class="caption"><%=Resources.Global.ACCORDION_HEADER_COMPANY_DETAILS_SUBTEXT %>
                                    </span>
                                </div>
                            </button>
                            <div class="bbs-accordion-content">
                                <div class="content-wrapper">
                                    <fieldset class="tw-flex tw-flex-col tw-gap-4" disabled>
                                        <div class="bbs-checkbox-input">
                                            <input type="checkbox" id="chkNewListingsOnly" runat="server" class="postback" />
                                            <label for="<%= chkNewListingsOnly.ClientID%>"><%= Resources.Global.NewListingsOnly %></label>

                                            <span id="NewListingRange" class="input-wrapper tw-flex tw-gap-2 flex-row tw-items-center">
                                                <label for="<%=ddlNewListingRange.ClientID %>"><%= Resources.Global.ListedInPast %></label>
                                                <asp:DropDownList ID="ddlNewListingRange" runat="server" CssClass="postback" />
                                            </span>
                                        </div>

                                        <div class="input-wrapper">
                                            <label for="companyName"><%=Resources.Global.CompanyName %></label>
                                            <p>
                                                <asp:TextBox ID="txtCompanyName"
                                                    CssClass="full-width postback"
                                                    type="text"
                                                    runat="server" />
                                            </p>
                                            <p class="caption">
                                                <%=Resources.Global.UseTheQuickSearchField %>
                                            </p>
                                        </div>
                                        <div class="input-wrapper">
                                            <p class="label"><%=Resources.Global.Type %></p>
                                            <div class="tw-flex tw-gap-4">
                                                <asp:RadioButtonList ID="rblCompanyType" runat="server" RepeatLayout="UnorderedList" CssClass="bbs-radio-input-group postback" />
                                            </div>
                                        </div>
                                        <div class="input-wrapper">
                                            <p class="label"><%=Resources.Global.ListingStatus %></p>
                                            <div class="tw-flex tw-gap-4">
                                                <asp:DropDownList ID="ddlListingStatus" runat="server" CssClass="postback"/>
                                            </div>
                                        </div>
                                        <div class="input-wrapper">
                                            <label for="phonenumber"><%=Resources.Global.Phone2 %></label>
                                            <p>
                                                <asp:TextBox ID="txtPhoneNumber"
                                                    runat="server"
                                                    CssClass="full-width postback"
                                                    type="text" />
                                            </p>
                                            <div class="bbs-checkbox-input tw-hidden">
                                                <input type="checkbox" id="chkPhoneNotNull" runat="server" class="postback">
                                                <label for="<%=chkPhoneNotNull.ClientID%>"><%=Resources.Global.MustHaveAPhoneNumber %></label>
                                            </div>
                                            <p class="caption">
                                            </p>
                                        </div>
                                        <div class="input-wrapper">
                                            <label for="companyemail"><%=Resources.Global.CompanyEmail %></label>
                                            <p>
                                                <asp:TextBox ID="txtEmail"
                                                    runat="server"
                                                    CssClass="full-width postback"
                                                    type="text" />
                                            </p>
                                            <div class="bbs-checkbox-input">
                                                <input type="checkbox" id="chkEmailNotNull" runat="server" class="postback">
                                                <label for="<%=chkEmailNotNull.ClientID%>"><%=Resources.Global.MustHaveAnEmailAddress %></label>
                                            </div>
                                        </div>
                                    </fieldset>
                                </div>
                            </div>
                        </asp:Panel>
                        <!-- Rating -->
                        <asp:Panel ID="pnlRatingForm" CssClass="bbs-accordion-item" runat="server">
                            <button
                                onclick="toggleAccordion(event); event.preventDefault();"
                                class="bbs-accordion-header">
                                <div>
                                    <span class="msicon notranslate expand-icon">expand_more</span>
                                </div>
                                <div class="label">
                                    <span class="text-label"><%=Resources.Global.Rating %></span>
                                    <span class="caption"><%=Resources.Global.BBSScoreOrRating %></span>
                                </div>
                            </button>
                            <div class="bbs-accordion-content">
                                <div class="content-wrapper">
                                    <fieldset class="tw-flex tw-flex-col tw-gap-4" disabled>
                                        <div data-info="Trading checkbox" class="input-wrapper">
                                            <div class="bbs-checkbox-input">
                                                <input type="checkbox" id="chkTMFMNotNull" runat="server" class="postback">
                                                <label for="<%=chkTMFMNotNull.ClientID%>"><%=Resources.Global.TradingTransportationMembersOnly %></label>
                                            </div>
                                        </div>
                                        <div data-info="Blue Book Score" class="input-wrapper">
                                            <p class="label">
                                                <label for="<%=txtBBScore.ClientID%>"><%=Resources.Global.BlueBookScore %></label>
                                                <button
                                                    runat="server"
                                                    type="button"
                                                    class="msicon notranslate help"
                                                    data-bs-toggle="tooltip"
                                                    data-bs-placement="right"
                                                    data-bs-html="true"
                                                    data-bs-title="<%$Resources:Global,BBScoreDefinition %>">
                                                    help
                                                </button>
                                            </p>
                                            <p class="tw-flex tw-gap-4">
                                                <asp:DropDownList ID="ddlBBScoreSearchType" runat="server" CssClass="postback" />
                                                <asp:TextBox ID="txtBBScore"
                                                    CssClass="full-width postback"
                                                    type="text"
                                                    runat="server" />
                                            </p>
                                        </div>

                                        <asp:Panel ID="trIntegrityRating" runat="server">
                                            <div data-info="<%= Resources.Global.IntegrityAbilityRating %>">
                                                <p class="label tw-mb-2"><%= Resources.Global.IntegrityAbilityRating %></p>
                                                <div class="tw-grid tw-grid-cols-2 tw-gap-x-4">
                                                    <asp:PlaceHolder ID="phIntegrityRating" runat="server"></asp:PlaceHolder>
                                                </div>
                                            </div>
                                        </asp:Panel>

                                        <hr />

                                        <asp:Panel ID="pnlPayDescription" runat="server">
                                            <div data-info="<%= Resources.Global.PayDescription %>" id="trPayDescription" runat="server">
                                                <p class="label tw-mb-2"><%= Resources.Global.PayDescription %></p>
                                                <div class="tw-grid tw-grid-cols-2 tw-gap-x-4">
                                                    <asp:PlaceHolder ID="phPayDescription" runat="server"></asp:PlaceHolder>
                                                </div>
                                            </div>
                                        </asp:Panel>

                                        <hr />

                                        <div data-info="<%= Resources.Global.CreditWorthRating %>">
                                            <p class="label">
                                                <span><%= Resources.Global.CreditWorthRating %></span>
                                                <button
                                                    runat="server" type="button"
                                                    class="msicon notranslate help"
                                                    tabindex="0"
                                                    data-bs-toggle="tooltip"
                                                    data-bs-placement="right"
                                                    data-bs-html="true"
                                                    data-bs-title="<%$Resources:Global,Help_M_Equals_Thousand %>">help
                                                </button>
                                            </p>
                                            <asp:Panel ID="pnlCreditWorthRating" runat="server">
                                                <div class="tw-grid tw-grid-cols-2 tw-gap-x-4">
                                                    <div class="input-wrapper">
                                                        <label for="min-score"><%=Resources.Global.Min %></label>
                                                        <asp:DropDownList ID="ddlCreditWorthRating_Min" runat="server" CssClass="postback" />
                                                    </div>
                                                    <div class="input-wrapper">
                                                        <label for="min-score"><%=Resources.Global.Max %></label>
                                                        <asp:DropDownList ID="ddlCreditWorthRating_Max" runat="server" CssClass="postback" />
                                                    </div>
                                                </div>
                                            </asp:Panel>
                                            <asp:Panel ID="pnlCreditWorthRating_L" runat="server">
                                                <div class="tw-grid tw-grid-cols-2 tw-gap-x-4">
                                                    <div class="input-wrapper">
                                                        <label for="min-score"><%=Resources.Global.Min %></label>
                                                        <asp:DropDownList ID="ddlCreditWorthRating_Min_L" runat="server" CssClass="postback" />
                                                    </div>
                                                    <div class="input-wrapper">
                                                        <label for="min-score"><%=Resources.Global.Max %></label>
                                                        <asp:DropDownList ID="ddlCreditWorthRating_Max_L" runat="server" CssClass="postback" />
                                                    </div>
                                                </div>
                                            </asp:Panel>
                                        </div>
                                    </fieldset>
                                </div>
                            </div>
                        </asp:Panel>

                        <!-- Location -->
                        <asp:Panel ID="pnlLocationForm" CssClass="bbs-accordion-item" runat="server">
                            <button
                                onclick="toggleAccordion(event); event.preventDefault()"
                                class="bbs-accordion-header">
                                <div>
                                    <span class="msicon notranslate expand-icon">expand_more</span>
                                </div>
                                <div class="label">
                                    <span class="text-label"><%=Resources.Global.Location %></span>
                                    <span class="caption"><%=Resources.Global.LocationCaption %></span>
                                </div>
                            </button>
                            <div class="bbs-accordion-content">
                                <div class="content-wrapper">
                                    <fieldset class="tw-flex tw-flex-col tw-gap-4" disabled>
                                        <div
                                            data-info="Country Selection"
                                            class="input-wrapper">
                                            <p class="label"><%=Resources.Global.Country %></p>

                                            <div class="tw-mt-2 tw-flex tw-gap-8">
                                                <div class="bbs-radio-input">
                                                    <input
                                                        type="radio"
                                                        id="radio_country_usa"
                                                        name="select-country"
                                                        onchange="mulSel_createOpt_CountryState('1'); refreshTerminalMarkets();"
                                                        value="1"
                                                        runat="server"
                                                        class="postback" />
                                                    <label for="<%=radio_country_usa.ClientID %>">USA</label>
                                                </div>
                                                <div class="bbs-radio-input">
                                                    <input
                                                        type="radio"
                                                        id="radio_country_canada"
                                                        name="select-country"
                                                        onchange="mulSel_createOpt_CountryState('2'); refreshTerminalMarkets();"
                                                        value="2"
                                                        runat="server"
                                                        class="postback" />
                                                    <label for="<%=radio_country_canada.ClientID %>">Canada</label>
                                                </div>
                                                <div class="bbs-radio-input">
                                                    <input
                                                        type="radio"
                                                        id="radio_country_mexico"
                                                        name="select-country"
                                                        onchange="mulSel_createOpt_CountryState('3'); refreshTerminalMarkets();"
                                                        value="3"
                                                        runat="server"
                                                        class="postback" />
                                                    <label for="<%=radio_country_mexico.ClientID %>">Mexico</label>
                                                </div>
                                                <div class="bbs-radio-input">
                                                    <input
                                                        type="radio"
                                                        id="radio_country_none"
                                                        name="select-country"
                                                        onchange="selectNoneCountry(event); refreshTerminalMarkets();"
                                                        value="0"
                                                        runat="server"
                                                        class="postback" />
                                                    <label for="<%=radio_country_none.ClientID%>"><%=Resources.Global.None %></label>
                                                </div>
                                            </div>
                                            <div data-info="Other Country" class="input-wrapper">
                                                <div class="tw-flex tw-items-center tw-gap-4">
                                                    <div class="bbs-radio-input">
                                                        <input
                                                            type="radio"
                                                            id="radio_country_other"
                                                            name="select-country"
                                                            onchange="enableOtherCountriesInput('otherCountries')"
                                                            value="other"
                                                            runat="server"
                                                            class="postback" />
                                                        <label for="radio_country_other"><%=Resources.Global.Other %></label>
                                                    </div>

                                                    <div class="tw-w-full">
                                                        <select
                                                            class="tw-w-full postback"
                                                            aria-label="Default select example"
                                                            id="otherCountries"
                                                            disabled>
                                                        </select>


                                                    </div>
                                                </div>
                                            </div>

                                            <p class="caption">
                                                <%=Resources.Global.OtherCaption %>
                                            </p>
                                        </div>
                                        <fieldset
                                            id="us_canada_mexico_state"
                                            disabled
                                            class="tw-flex tw-flex-col tw-gap-4">
                                            <div
                                                data-info="State Selection"
                                                class="input-wrapper">
                                                <label for="na-states-input"><%=Resources.Global.State %></label>

                                                <div
                                                    class="bbs-mulSel"
                                                    id="countryState-mulSel">
                                                    <div class="mulSel-tag-container"></div>
                                                    <div
                                                        class="bbs-mulSel-input"
                                                        data-bs-toggle="dropdown"
                                                        aria-expanded="false"
                                                        data-bs-auto-close="outside">
                                                        <input
                                                            placeholder="<%=Resources.Global.SelectOrSearchForState %>"
                                                            type="text"
                                                            class="tw-w-full"
                                                            id="na-states-input"
                                                            onkeydown="mulSel_onkeydown(event)"
                                                            oninput="mulSel_oninput(event)" />

                                                        <button
                                                            class="bbsButton bbsButton-secondary"
                                                            type="button">
                                                            <span class="msicon notranslate">expand_more
                                                            </span>
                                                        </button>
                                                    </div>
                                                    <ul class="dropdown-menu tw-w-full" role="menu">
                                                        <!-- // this will be filled by javascript function
                                                        // mulSel_createOpt_CountryState (country)-->
                                                    </ul>
                                                </div>
                                                <p class="caption"><%=Resources.Global.USCanadaMexicoOnly %></p>
                                            </div>
                                        </fieldset>
                                        <fieldset
                                        id="us_canada_mexico_city"
                                        disabled
                                        class="tw-flex tw-flex-col tw-gap-4"
                                        >
                                            <div data-info="City Selection" class="input-wrapper">
                                                <label for="<%=txtListingCity.ClientID %>"><%=Resources.Global.City %></label>

                                                <p>
                                                    <asp:TextBox ID="txtListingCity"
                                                        CssClass="full-width postback"
                                                        type="text" runat="server" autocomplete="off" />
                                                    <cc1:AutoCompleteExtender ID="aceListingCity" runat="server"
                                                        TargetControlID="txtListingCity"
                                                        BehaviorID="aceListingCity"
                                                        ServiceMethod="GetCityCompletionList2"
                                                        ServicePath="AJAXHelper.asmx"
                                                        CompletionInterval="100"
                                                        MinimumPrefixLength="2"
                                                        CompletionSetCount="20"
                                                        CompletionListCssClass="AutoCompleteFlyout"
                                                        CompletionListItemCssClass="AutoCompleteFlyoutItem"
                                                        CompletionListHighlightedItemCssClass="AutoCompleteFlyoutHilightedItem"
                                                        CompletionListElementID="pnlCityAutoComplete"
                                                        OnClientPopulated="aceCityPopulated"
                                                        OnClientPopulating="aceCityPopulating2"
                                                        OnClientItemSelected="aceCitySelected2"
                                                        DelimiterCharacters="|"
                                                        EnableCaching="False"
                                                        UseContextKey="True"
                                                        ContextKey=""
                                                        FirstRowSelected="true">
                                                    </cc1:AutoCompleteExtender>
                                                </p>
                                                <p class="caption"><%=Resources.Global.USCanadaMexicoOnly %></p>
                                            </div>
                                        </fieldset>

                                        <asp:Panel ID="pnlTerminalMarkets" runat="server">
                                            <div data-info="Terminal Markets" class="input-wrapper">
                                                <fieldset id="fsTerminalMarkets" runat="server">
                                                    <label for="tm-input"><%=Resources.Global.TerminalMarkets %></label>

                                                    <div
                                                        class="bbs-mulSel"
                                                        id="terminalMkt-mulSel">
                                                        <div class="mulSel-tag-container"></div>

                                                        <div
                                                            class="bbs-mulSel-input"
                                                            data-bs-toggle="dropdown"
                                                            aria-expanded="false"
                                                            data-bs-auto-close="outside">
                                                            <input
                                                                placeholder="<%=Resources.Global.AddTerminalMarkets %>"
                                                                type="text"
                                                                class="tw-w-full"
                                                                id="tm-input"
                                                                onkeydown="mulSel_onkeydown(event)"
                                                                oninput="mulSel_oninput(event)" />

                                                            <button
                                                                class="bbsButton bbsButton-secondary"
                                                                type="button">
                                                                <span class="msicon notranslate">expand_more
                                                                </span>
                                                            </button>
                                                        </div>
                                                        <ul class="dropdown-menu tw-w-full" role="menu">
                                                            <!-- // this will be filled by javascript function
                                                    // mulSel_createOpt_CountryState (country)-->
                                                        </ul>
                                                    </div>
                                                </fieldset>
                                            </div>
                                        </asp:Panel>
                                        <hr />
                                        <asp:Panel ID="pnlRadius" runat="server">
                                            <div data-info="Distance" class="input-wrapper">
                                                <fieldset id="fsRadius" runat="server">
                                                    <label for="<%=txtRadius.ClientID%>"><%=Resources.Global.Distance %></label>
                                                    <p>
                                                        <input
                                                            class="full-width postback"
                                                            id="txtRadius"
                                                            type="text"
                                                            runat="server" />
                                                    </p>
                                                    <p class="caption">
                                                        <%=Resources.Global.DistanceMessage %>
                                                    </p>

                                                    <div class="tw-mt-1 tw-flex tw-items-center tw-gap-4">
                                                        <div class="bbs-radio-input tw-w-[150px]">
                                                            <input
                                                                type="radio"
                                                                id="zipcode_distance"
                                                                name="distance-from"
                                                                onchange="toggleZipcodeInput(true, 'contentMain_txtZipCode')"
                                                                runat="server"
                                                                class="postback"
                                                                value="Listing Postal Code" />
                                                            <label for="<%=zipcode_distance.ClientID %>"><%=Resources.Global.ZipCode %></label>
                                                        </div>
                                                        <input
                                                            class="full-width postback"
                                                            id="txtZipCode"
                                                            type="text"
                                                            placeholder="e.g. M5V 3L9 or 10035"
                                                            runat="server" />
                                                    </div>
                                                    <div class="bbs-radio-input tw-w-[150px]">
                                                        <input
                                                            type="radio"
                                                            id="terminal_market_distance"
                                                            name="distance-from"
                                                            onchange="toggleZipcodeInput(false, 'contentMain_txtZipCode')"
                                                            runat="server"
                                                            class="postback"
                                                            value="Terminal Market" />

                                                        <label for="<%=terminal_market_distance.ClientID%>"><%=Resources.Global.TerminalMarket %></label>
                                                    </div>
                                                </fieldset>
                                            </div>
                                        </asp:Panel>
                                    </fieldset>
                                </div>
                            </div>
                        </asp:Panel>

                        <!-- Commodities -->
                        <asp:Panel ID="pnlCommodityForm" runat="server" CssClass="bbs-accordion-item">
                            <button
                                onclick="toggleAccordion(event); event.preventDefault()"
                                class="bbs-accordion-header">
                                <div>
                                    <span class="msicon notranslate expand-icon">expand_more</span>
                                </div>
                                <div class="label">
                                    <span class="text-label"><%=Resources.Global.Commodities %></span>
                                    <span class="caption"><%=Resources.Global.TypesOfFruitsVegsEtc %></span>
                                </div>
                            </button>
                            <div class="bbs-accordion-content">
                                <div class="content-wrapper">
                                    <fieldset class="tw-flex tw-flex-col tw-gap-4" disabled>
                                        <!-- Matching Criteria -->
                                        <div class="input-wrapper">
                                            <p class="label"><%=Resources.Global.MatchingCriteria %></p>

                                            <div class="tw-mt-2 tw-flex tw-gap-8">
                                                <asp:RadioButtonList ID="rblCommoditySearchType" runat="server" RepeatLayout="UnorderedList" CssClass="bbs-radio-input-group postback tw-grid tw-grid-cols-2" />
                                            </div>
                                        </div>
                                        <hr />
                                        <!-- Commodities -->
                                        <asp:Panel ID="pnlCommodityList" runat="server" data-info="Categories" CssClass="input-wrapper">
                                            <div class="tw-flex tw-justify-between">
                                                <label for="commodity-categories-input"><%=Resources.Global.Commodities%></label>
                                                <a
                                                    href="KnowYourCommodity.aspx"
                                                    class="bbsButton bbsButton-secondary small"
                                                    target="_blank">
                                                    <span class="msicon notranslate">help</span>
                                                    <span class="text-label">KYC</span>
                                                    <span class="msicon notranslate">arrow_outward</span>
                                                </a>
                                            </div>
                                            <div class="bbs-mulSel" id="commodity-mulSel">
                                                <div class="mulSel-tag-container"></div>

                                                <div
                                                    class="bbs-mulSel-input"
                                                    data-bs-toggle="dropdown"
                                                    aria-expanded="false"
                                                    data-bs-auto-close="outside">
                                                    <input
                                                        placeholder="<%=Resources.Global.AddCommodities %>"
                                                        type="text"
                                                        class="tw-w-full"
                                                        id="commodity-categories-input"
                                                        onkeydown="mulSel_onkeydown(event)"
                                                        oninput="mulSel_oninput(event)" />

                                                    <button
                                                        class="bbsButton bbsButton-secondary"
                                                        type="button">
                                                        <span class="msicon notranslate">expand_more
                                                        </span>
                                                    </button>
                                                </div>
                                                <ul class="dropdown-menu tw-w-full" role="menu">
                                                    <!-- // this will be filled by javascript function
                                                    // mulSel_createOpt_CountryState (country)-->
                                                </ul>
                                            </div>
                                        </asp:Panel>

                                        <hr />

                                        <asp:Panel ID="pnlExpandedContents" runat="server">
                                            <!-- Growing Method -->
                                            <div class="input-wrapper">
                                                <p class="label"><%= Resources.Global.GrowingMethod %></p>
                                                <div class="tw-mt-2 tw-flex tw-flex-wrap tw-gap-x-4">
                                                    <asp:RadioButtonList ID="rblGrowingMethod" runat="server" RepeatLayout="UnorderedList" CssClass="bbs-radio-input-group postback" />
                                                </div>
                                                <br />
                                            </div>
                                            <hr />
                                            <br />
                                            <!-- Attributes -->
                                            <div class="input-wrapper">
                                                <label for="attributes"><%=Resources.Global.Attributes %></label>
                                                <p class="caption">
                                                    <span class="msicon notranslate">warning</span>
                                                    <%=Resources.Global.OneAttributeSupported %>
                                                </p>
                                                <asp:Literal ID="litAttributes" runat="server" />
                                            </div>
                                        </asp:Panel>
                                    </fieldset>
                                </div>
                            </div>
                        </asp:Panel>

                        <!-- Classification -->
                        <asp:Panel ID="pnlClassificationForm" runat="server" CssClass="bbs-accordion-item">
                            <button
                                onclick="toggleAccordion(event)"
                                class="bbs-accordion-header">
                                <div>
                                    <span class="msicon notranslate expand-icon">expand_more</span>
                                </div>
                                <div class="label">
                                    <span class="text-label"><%=Resources.Global.Classifications %></span>
                                    <span class="caption"><%=Resources.Global.ClassificationsCaption %>
                                    </span>
                                </div>
                            </button>
                            <div class="bbs-accordion-content">
                                <div class="content-wrapper">
                                    <fieldset class="tw-flex tw-flex-col tw-gap-4" disabled>
                                        <!-- Rejected shipment -->
                                        <div class="input-wrapper" runat="server" id="pnlRejectedShipments">
                                            <p class="label">
                                                <span><%=Resources.Global.RejectedShipments %></span>
                                                <button
                                                    runat="server"
                                                    type="button"
                                                    class="msicon notranslate help"
                                                    data-bs-toggle="tooltip"
                                                    data-bs-placement="right"
                                                    data-bs-html="true"
                                                    data-bs-title="<%$Resources:Global,ShowCompaniesThatTakeRejectedShipments %>">
                                                    help
                                                </button>
                                            </p>
                                            <div class="bbs-checkbox-input">
                                                <input type="checkbox" id="cbSalvageDistressedProduce" runat="server" class="postback" />
                                                <label for="<%=cbSalvageDistressedProduce.ClientID %>"><%=Resources.Global.HandlesRejectedShipments %></label>

                                                <br />
                                            </div>

                                            <hr />
                                        </div>
                                        
                                        <!-- Matching Criteria -->
                                        <div class="input-wrapper">
                                            <p class="label"><%=Resources.Global.MatchingCriteria %></p>
                                            <div class="tw-mt-2 tw-flex tw-gap-8">
                                                <asp:RadioButtonList ID="rblClassSearchType" runat="server" RepeatLayout="UnorderedList" CssClass="bbs-radio-input-group postback tw-grid tw-grid-cols-2" />
                                            </div>
                                        </div>
                                        <hr />
                                        <asp:Panel ID="pnlProduceClass" runat="server" CssClass="tw-flex tw-gap-4 tw-flex-col" />
                                        <asp:Panel ID="pnlTransportationClass" runat="server" CssClass="tw-flex tw-gap-4 tw-flex-col" />
                                        <asp:Panel ID="pnlSupplyClass" runat="server" CssClass="tw-flex tw-gap-4 tw-flex-col" />
                                        <asp:Panel ID="pnlLumberClass" runat="server" CssClass="tw-flex tw-gap-4 tw-flex-col" />

                                        <%--Number of Retail Stores--%>
                                        <asp:Panel ID="pnlNumberOfStores" runat="server" CssClass="tw-hidden tw-flex tw-gap-4 tw-flex-col" ClientIDMode="Static">
                                            <fieldset id="fsNumOfRetail" runat="server" class="tw-flex tw-flex-col tw-gap-4">
                                                <div class="label">
                                                    <asp:Label ID="lblRetailStores" runat="server" Enabled="false"><%= ((string)Resources.Global.NumberOfRetailStores).Replace("<br />"," ") %></asp:Label>
                                                </div>

                                                <asp:CheckBoxList ID="cblNumOfRetail" runat="server" RepeatColumns="4" RepeatDirection="Horizontal"
                                                    Width="100%"
                                                    RepeatLayout="Table"
                                                    CssClass="checkboxlist-4col nowraptd_wraplabel norm_lbl postback" />
                                            </fieldset>
                                            <fieldset id="fsNumOfRestaurant" runat="server" class="tw-flex tw-flex-col tw-gap-4">
                                                <div class="label">
                                                    <asp:Label ID="lblRestaurantStores" runat="server" Enabled="false"><%= ((string)Resources.Global.NumberOfRestaurantStores).Replace("<br />"," ") %></asp:Label>
                                                </div>

                                                <asp:CheckBoxList ID="cblNumOfRestaurants" runat="server" RepeatColumns="4" RepeatDirection="Horizontal"
                                                    Width="100%"
                                                    CssClass="checkboxlist-4col nowraptd_wraplabel norm_lbl postback" />
                                            </fieldset>
                                        </asp:Panel>
                                    </fieldset>
                                </div>
                            </div>
                        </asp:Panel>

                        <!-- Licenses and Certifications -->
                        <asp:Panel ID="pnlLicensesForm" runat="server" CssClass="bbs-accordion-item">
                            <button
                                onclick="toggleAccordion(event)"
                                class="bbs-accordion-header">
                                <div>
                                    <span class="msicon notranslate expand-icon">expand_more</span>
                                </div>
                                <div class="label">
                                    <span id="licensesCertificationLabel" runat="server" class="text-label"></span>
                                    <span id="licensesCertificationCaption" runat="server" class="caption"></span>
                                </div>
                            </button>
                            <div class="bbs-accordion-content">
                                <div class="content-wrapper">
                                    <fieldset class="tw-flex tw-flex-col tw-gap-4" disabled>
                                        <!-- Certifications reported -->
                                        <div id="trCertifications" runat="server">
                                            <p class="label"><%=Resources.Global.CertificationsReported %></p>
                                            <p class="caption">
                                                <%=Resources.Global.CertificationsReportedCaption %>
                                            </p>
                                            <ul class="bbs-checkbox-input-group tw-grid tw-grid-cols-2 tw-gap-x-4">
                                                <li id="pnlCertifiedOrganic" runat="server">
                                                    <input type="checkbox" id="cbOrganic" runat="server" class="postback" />
                                                    <label for="<%=cbOrganic.ClientID %>">
                                                        <asp:Literal runat="server" Text="<%$ Resources:Global, CertifiedOrganic%>" />
                                                    </label>
                                                </li>
                                                <li>
                                                    <input type="checkbox" id="cbFoodSafety" runat="server" class="postback" />
                                                    <label for="<%=cbFoodSafety.ClientID %>">
                                                        <asp:Literal runat="server" Text="<%$ Resources:Global, FoodSafetyCertified%>" /></label>
                                                </li>
                                            </ul>
                                        </div>

                                        <!-- License Type -->
                                        <div id="trLicenseType" runat="server">
                                            <p class="label"><%=Resources.Global.LicenseType %></p>
                                            <asp:CheckBoxList ID="cblLicenseType" runat="server" RepeatLayout="UnorderedList" CssClass="bbs-checkbox-input-group tw-grid tw-grid-cols-2 tw-gap-x-4 postback" />
                                        </div>

                                        <!-- Brands -->
                                        <div id="pnlBrands" runat="server">
                                            <div class="input-wrapper">
                                                <label for="brands"><%=Resources.Global.Brands %></label>
                                                <p>
                                                    <asp:TextBox ID="txtBrands" runat="server" CssClass="full-width postback" />
                                                </p>
                                            </div>
                                        </div>
                                        <!-- Miscellaneous listing information -->
                                        <div>
                                            <div class="input-wrapper">
                                                <label for="Miscellaneous_listing_information"><%=Resources.Global.MiscListingInfo2 %></label>
                                                <p>
                                                    <asp:TextBox ID="txtMiscListingInfo" runat="server" CssClass="full-width postback" />
                                                </p>
                                            </div>
                                        </div>
                                        <!-- Volume -->
                                        <div id="trVolume" runat="server">
                                            <p class="label"><%=Resources.Global.Volume %></p>
                                            <p class="caption">
                                                <asp:Literal ID="lblVolumeText" Text="<%$ Resources:Global, VolumeText2 %>" runat="server" />
                                            </p>

                                            <div class="tw-grid tw-grid-cols-2 tw-gap-x-4">
                                                <div class="input-wrapper">
                                                    <label for="min-volume"><%=Resources.Global.Min %></label>

                                                    <asp:DropDownList ID="ddlVolume_Min" runat="server" CssClass="postback" />
                                                </div>
                                                <div class="input-wrapper">
                                                    <label for="max-volume"><%=Resources.Global.Max %></label>
                                                    <asp:DropDownList ID="ddlVolume_Max" runat="server" CssClass="postback" />
                                                </div>
                                            </div>
                                        </div>
                                    </fieldset>
                                </div>
                            </div>
                        </asp:Panel>

                        <!-- Local Source -->
                        <asp:Panel ID="pnlLocalSourceForm" runat="server" CssClass="bbs-accordion-item">
                            <button
                                onclick="toggleAccordion(event)"
                                class="bbs-accordion-header">
                                <div>
                                    <span class="msicon notranslate expand-icon">expand_more</span>
                                </div>
                                <div class="label">
                                    <span class="text-label"><%=Resources.Global.LocalSourceData %></span>
                                    <span class="caption"><%=Resources.Global.LocalSourceDataCaption %></span>
                                </div>
                            </button>
                            <div class="bbs-accordion-content">
                                <div class="content-wrapper">
                                    <fieldset disabled class="tw-flex tw-flex-col tw-gap-4">
                                        <p class="caption tw-text-text-secondary">
                                            <%= Resources.Global.MeisterMediaSearchPageMsg %>
                                        </p>

                                        <div class="input-wrapper">
                                            <p class="label">
                                                <span><%=Resources.Global.LocalSourceData2 %>:</span>
                                                <button
                                                    runat="server" type="button"
                                                    class="msicon notranslate help"
                                                    data-bs-toggle="tooltip"
                                                    data-bs-trigger="hover focus"
                                                    data-bs-placement="right"
                                                    data-bs-html="true"
                                                    data-bs-title="<%=Resources.Global.LocalSourceDataString %>">
                                                    help
                                                </button>
                                            </p>

                                            <p>
                                                <asp:DropDownList ID="ddlIncludeLocalSource" runat="server" CssClass="postback tw-w-full" />
                                            </p>
                                        </div>
                                        <div class="input-wrapper">
                                            <div class="bbs-checkbox-input">
                                                <input type="checkbox" id="cbCertifiedOrganic" runat="server" class="postback" />
                                                <label for="cbCertifiedOrganic"><%= Resources.Global.GrowsOrganic %></label><br />
                                            </div>
                                        </div>
                                        <div class="input-wrapper">
                                            <p class="label"><%= Resources.Global.LocalSourceData2 %></p>

                                            <asp:CheckBoxList ID="cblAlsoOperates" runat="server"
                                                RepeatLayout="UnorderedList" CssClass="bbs-checkbox-input-group tw-my-2 tw-grid tw-grid-cols-1 postback" />
                                                                                       
                                        </div>
                                        <div class="input-wrapper">
                                            <p class="label"><%= Resources.Global.TotalAcres %></p>
                                            <div class="tw-grid tw-grid-cols-2 tw-gap-x-4">
                                                <asp:PlaceHolder ID="phTotalAcres" runat="server"></asp:PlaceHolder>
                                            </div>
                                        </div>
                                    </fieldset>
                                </div>
                            </div>
                        </asp:Panel>

                        <!-- Custom Filters -->
                        <asp:Panel ID="pnlCustomFiltersForm" runat="server" CssClass="bbs-accordion-item">
                            <button
                                onclick="toggleAccordion(event)"
                                class="bbs-accordion-header">
                                <div>
                                    <span class="msicon notranslate expand-icon">expand_more</span>
                                </div>
                                <div class="label">
                                    <span class="text-label"><%=Resources.Global.CustomFilters %></span>
                                    <span class="caption"><%=Resources.Global.CustomFiltersCaption %></span>
                                </div>
                            </button>
                            <div class="bbs-accordion-content">
                                <div class="content-wrapper">
                                    <fieldset class="tw-flex tw-flex-col tw-gap-4" disabled>
                                        <asp:Panel ID="pnlWatchdogList" runat="server">
                                            <!-- Button trigger modal -->
                                            <button
                                                type="button"
                                                class="bbsButton bbsButton-secondary"
                                                data-bs-toggle="modal"
                                                data-bs-target="#watchdogModal">
                                                <span class="msicon notranslate">sound_detection_dog_barking</span>
                                                <span class="text-label"><%=Resources.Global.SelectWatchdog%></span>
                                                <span class="msicon notranslate">open_in_full</span>
                                            </button>

                                            <!-- Modal -->
                                            <div
                                                class="modal fade"
                                                id="watchdogModal"
                                                tabindex="-1"
                                                aria-labelledby="watchdogModalLabel"
                                                aria-hidden="true">

                                                <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg">
                                                    <div class="modal-content">
                                                        <div class="modal-header">
                                                            <h1 class="modal-title fs-5" id="watchdogModalLabel"><%= Resources.Global.SelectWatchdogListsText %></h1>

                                                            <button
                                                                type="button"
                                                                class="bbsButton bbsButton-tertiary"
                                                                data-bs-dismiss="modal"
                                                                aria-label="Close">
                                                                <span class="msicon notranslate">close</span>
                                                            </button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <div>
                                                                <asp:GridView ID="gvUserList"
                                                                    AllowSorting="true"
                                                                    runat="server"
                                                                    AutoGenerateColumns="false"
                                                                    CssClass="table table-striped table-hover"
                                                                    GridLines="None"
                                                                    OnSorting="UserListGridView_Sorting"
                                                                    OnRowDataBound="GridView_RowDataBound">

                                                                    <Columns>
                                                                        <asp:TemplateField HeaderStyle-CssClass="vertical-align-top text-center" ItemStyle-CssClass="text-center">
                                                                            <HeaderTemplate>
                                                                                <% =Resources.Global.Select%>
                                                                                <br />
                                                                                <% =GetCheckAllCheckbox("cbUserListID", "refreshCriteria();")%>
                                                                            </HeaderTemplate>

                                                                            <ItemTemplate>
                                                                                <input type="checkbox" name="cbUserListID" value="<%# Eval("prwucl_WebUserListID") %>"
                                                                                    <%# GetChecked((int)Eval("prwucl_WebUserListID")) %> onclick="refreshCriteria();" />
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>

                                                                        <asp:TemplateField HeaderText="<%$ Resources:Global, WatchdogListName %>" ItemStyle-CssClass="text-left" SortExpression="prwucl_Name" HeaderStyle-CssClass="vertical-align-top">
                                                                            <ItemTemplate>
                                                                                <a href="<%# PageConstants.Format(PageConstants.USER_LIST, Eval("prwucl_WebUserListID")) %>">
                                                                                    <%# PageControlBaseCommon.GetCategoryIcon(Eval("prwucl_CategoryIcon"), Eval("prwucl_Name"))%> <%# Eval("prwucl_Name")%>
                                                                                </a>
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                        <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, Private %>" SortExpression="prwucl_IsPrivate">
                                                                            <ItemTemplate><%# UIUtils.GetStringFromBool(Eval("prwucl_IsPrivate"))%> </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                        <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="vertical-align-top" HeaderText="<%$ Resources:Global, UpdatedDate %>" SortExpression="UpdatedDate">
                                                                            <ItemTemplate><%# GetStringFromDate(Eval("UpdatedDate"))%> </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                        <asp:BoundField HeaderText="<%$ Resources:Global, CompanyCount %>" DataField="CompanyCount" SortExpression="CompanyCount" HeaderStyle-CssClass="vertical-align-top" ItemStyle-CssClass="text-left vertical-align-top" />
                                                                    </Columns>
                                                                </asp:GridView>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button
                                                                type="button"
                                                                class="bbsButton bbsButton-secondary"
                                                                data-bs-dismiss="modal"
                                                                aria-label="Close">
                                                                <span class="text-label">Close</span>
                                                            </button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </asp:Panel>

                                        <div class="bbs-checkbox-input">
                                            <input type="checkbox" id="chkCompanyHasNotes" runat="server" class="postback">
                                            <label for="<%=chkCompanyHasNotes.ClientID%>"><%=Resources.Global.CompanyHasNotes %></label>
                                        </div>

                                        <asp:Repeater OnItemCreated="repCustomFields_ItemCreated" ID="repCustomFields" runat="server">
                                            <ItemTemplate>
                                                <asp:PlaceHolder ID="phCustomField" runat="server" />
                                            </ItemTemplate>
                                        </asp:Repeater>

                                    </fieldset>
                                </div>
                            </div>
                        </asp:Panel>

                        <!-- Internal Criteria -->
                        <asp:Panel ID="pnlInternalCriteriaForm" runat="server" CssClass="bbs-accordion-item">
                            <button
                                onclick="toggleAccordion(event)"
                                class="bbs-accordion-header">
                                <div>
                                    <span class="msicon notranslate expand-icon">expand_more</span>
                                </div>
                                <div class="label">
                                    <span class="text-label"><%=Resources.Global.btnInternalCriteria %></span>
                                    <span class="caption"><%=Resources.Global.InternalCriteria_Caption %>
                                    </span>
                                </div>
                            </button>
                            <div class="bbs-accordion-content">
                                <div class="content-wrapper">
                                    <fieldset class="tw-flex tw-flex-col tw-gap-4" disabled>
                                        <div class="input-wrapper">
                                            <p class="label"><%=Resources.Global.SalesTerritory %></p>
                                            <asp:CheckBoxList ID="cblSalesTerritory" runat="server"
                                                RepeatLayout="UnorderedList" CssClass="bbs-checkbox-input-group tw-my-2 tw-grid tw-grid-cols-4 tw-gap-4 postback" />
                                        </div>
                                        <div class="input-wrapper">
                                            <label for="<%=ddlTerritoryCode.ClientID %>"><%=Resources.Global.TerritoryCode %></label>
                                            <p>
                                                <asp:DropDownList ID="ddlTerritoryCode" runat="server" CssClass="tw-w-full postback" />
                                            </p>
                                        </div>
                                        <div class="input-wrapper">
                                            <label for="contentMain_ddlMembershipTypeCode"><%=Resources.Global.MembershipType %></label>
                                            <p>
                                                <asp:DropDownList ID="ddlMembershipTypeCode" runat="server" CssClass="tw-w-full postback" />
                                            </p>
                                        </div>
                                        <div class="input-wrapper">
                                            <p class="label"><%=Resources.Global.PrimaryService %></p>
                                            <asp:CheckBoxList ID="cblPrimaryService" runat="server"
                                                RepeatLayout="UnorderedList" CssClass="bbs-checkbox-input-group tw-my-2 tw-grid tw-grid-cols-4 tw-gap-4 postback" />
                                        </div>
                                        <div class="input-wrapper">
                                            <label for="<%=txtAvailLicense.ClientID %>"><%=Resources.Global.NumAvailLicenses %></label>
                                            <p class="tw-flex tw-gap-4">
                                                <asp:DropDownList ID="ddlAvailLicenseSearchType" runat="server" CssClass="postback" />
                                                <asp:TextBox ID="txtAvailLicense" runat="server" MaxLength="3" CssClass="full-width postback" />
                                            </p>
                                        </div>
                                        <div class="input-wrapper">
                                            <label for="<%=txtActiveLicense.ClientID %>"><%=Resources.Global.NumActiveLicenses %></label>
                                            <p class="tw-flex tw-gap-4">
                                                <asp:DropDownList ID="ddlActiveLicenseSearchType" runat="server" CssClass="postback" />
                                                <asp:TextBox ID="txtActiveLicense" runat="server" MaxLength="3" CssClass="full-width postback" />
                                            </p>
                                        </div>
                                        <div class="input-wrapper">
                                            <label for="<%=txtAvailableUnits.ClientID %>"><%=Resources.Global.NumBusReportsAvail%></label>
                                            <p class="tw-flex tw-gap-4">
                                                <asp:DropDownList ID="ddlAvailableUnitsSearchType" runat="server" CssClass="postback" />
                                                <asp:TextBox ID="txtAvailableUnits" runat="server" MaxLength="5" CssClass="full-width postback" />
                                            </p>
                                        </div>
                                        <div class="input-wrapper">
                                            <label for="<%=txtUsedUnits.ClientID %>"><%=Resources.Global.NumBusReportsUsed %></label>
                                            <p class="tw-flex tw-gap-4">
                                                <asp:DropDownList ID="ddlUsedUnitsSearchType" runat="server" CssClass="postback" />
                                                <asp:TextBox ID="txtUsedUnits" runat="server" MaxLength="5" CssClass="full-width postback" />
                                            </p>
                                        </div>

                                        <div class="bbs-checkbox-input">
                                            <input type="checkbox" id="cbReceivesPromoFaxes" runat="server" class="postback" />
                                            <label class="strong" for="<%=cbReceivesPromoFaxes.ClientID %>"><%=Resources.Global.ReceivesPromoFaxes %></label>
                                            <br />
                                        </div>

                                        <div class="bbs-checkbox-input">
                                            <input type="checkbox" id="cbReceivesPromoEmails" runat="server" class="postback" />
                                            <label class="strong" for="<%=cbReceivesPromoEmails.ClientID %>"><%=Resources.Global.ReceivesPromoEmails %></label>
                                            <br />
                                        </div>

                                        <div class="input-wrapper">
                                            <label for="<%=txtMembershipRevenue.ClientID %>"><%=Resources.Global.MembershipRevenue %></label>
                                            <p class="tw-flex tw-gap-4">
                                                <asp:DropDownList ID="ddlMembershipRevenueSearchType" runat="server" CssClass="postback" />
                                                <asp:TextBox ID="txtMembershipRevenue" runat="server" MaxLength="8" CssClass="full-width postback" />
                                            </p>
                                        </div>
                                        <div class="input-wrapper">
                                            <label for="<%=txtAdvertisingRevenue.ClientID %>"><%=Resources.Global.AdvertisingRevenue %></label>
                                            <p class="tw-flex tw-gap-4">
                                                <asp:DropDownList ID="ddlAdvertisingRevenueSearchType" runat="server" CssClass="postback" />
                                                <asp:TextBox ID="txtAdvertisingRevenue" runat="server" MaxLength="8" CssClass="full-width postback" />
                                            </p>
                                        </div>
                                    </fieldset>
                                </div>
                            </div>
                        </asp:Panel>
                    </div>
                </div>
            </div>
            <%--SECTION: Selected Criteria--%>
            <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional" class="selected-criteria" >
                <ContentTemplate>
                    <div style="display: none">
                        <asp:Button ID="btnUpdatePanel" runat="server" />
                    </div>

                    <div>
                        <div class="tw-sticky tw-top-0 tw-bg-bg-secondary tw-pb-2">
                            <h2><%=Resources.Global.SelectedCriteria %></h2>
                            <div class="tw-flex tw-gap-2">
                                <asp:LinkButton ID="btnClearAllCriteria" runat="server" CssClass="bbsButton bbsButton-secondary filled full-width" OnClick="btnClearAllCriteria_Click" type="button">
                                    <span class="msicon notranslate">clear_all</span>
                                    <span> <asp:Literal runat="server" Text="<%$Resources:Global, ClearAll%>" /></span>
                                </asp:LinkButton>

                                <asp:LinkButton ID="btnSaveSearch" runat="server" CssClass="bbsButton bbsButton-secondary filled full-width" OnClick="btnSaveSearch_Click" type="button">
                                    <span class="msicon notranslate">saved_search</span>
                                    <span> <asp:Literal runat="server" Text="<%$Resources:Global, SaveSearch%>" /></span>
                                </asp:LinkButton>

                                <asp:LinkButton
                                    type="button"
                                    ID="btnSearch"
                                    runat="server"
                                    CssClass="bbsButton bbsButton-primary full-width" OnClick="btnSearch_Click">
                                        <span class="msicon notranslate">search</span>
                                        <span><asp:Literal runat="server" Text="<%$Resources:Global, Search%>" /></span>
                                </asp:LinkButton>
                            </div>
                        </div>

                        <uc1:AdvancedCompanySearchCriteriaControl ID="ucAdvancedCompanySearchCriteriaControl" runat="server" />
                    </div>

                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </asp:Panel>
</asp:Content>

<asp:Content ID="contentLeftSidebar" ContentPlaceHolderID="contentLeftSidebar" runat="server">

    <aside class="offcanvas-lg offcanvas-start nav-sidebar" id="bdSidebar">
        <div class="offcanvas-header border-bottom">
            <h5 class="offcanvas-title" id="bdSidebarOffcanvasLabel"><%=Resources.Global.AdvancedCompanySearch %></h5>
            <button
                type="button"
                class="bbsButton bbsButton-tertiary"
                data-bs-dismiss="offcanvas"
                aria-label="Close"
                data-bs-target="#bdSidebar">
              <span class="msicon notranslate">close</span>
            </button>
        </div>
        <div class="accordion accordion-flush" id="accordionFlushExample">
            <!-- IndustryType -->
            <div class="accordion-item">
                <div class="accordion-header">
                    <button
                        class="accordion-button"
                        type="button"
                        data-bs-toggle="collapse"
                        data-bs-target="#flush_collapseOne"
                        aria-expanded="false"
                        aria-controls="flush_collapseOne">
                        <span class="group-label"><%=Resources.Global.IndustryType %></span>
                    </button>
                </div>
                <div
                    id="flush_collapseOne"
                    class="accordion-collapse collapse show">

                    <asp:LinkButton ID="btnProduce" runat="server" OnClick="btnIndustry_Click"
                        CssClass="bbs-menu-item new selected">
                    
                        <span class="msicon notranslate">psychiatry</span>
                        <div class="text-content">
                            <span class="label"><%=Resources.Global.Produce %></span>
                        </div>
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnTransport" runat="server" OnClick="btnIndustry_Click"
                        CssClass="bbs-menu-item new">
                    
                        <span class="msicon notranslate">local_shipping</span>
                        <div class="text-content">
                            <span class="label"><%=Resources.Global.Transport %></span>
                        </div>
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnSupply" runat="server" OnClick="btnIndustry_Click"
                        CssClass="bbs-menu-item new">
                    
                        <span class="msicon notranslate">conveyor_belt</span>
                        <div class="text-content">
                            <span class="label"><%=Resources.Global.Supply %></span>
                        </div>
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnLumber" runat="server" OnClick="btnIndustry_Click"
                        CssClass="bbs-menu-item new"
                        Visible="false">
                    
                        <span class="msicon notranslate">conveyor_belt</span>
                        <div class="text-content">
                            <span class="label"><%=Resources.Global.Lumber %></span>
                        </div>
                    </asp:LinkButton>
                </div>
            </div>

            <!-- My Lists -->
            <div class="accordion-item">
                <div class="accordion-header">
                    <button
                        class="accordion-button"
                        type="button"
                        data-bs-toggle="collapse"
                        data-bs-target="#flush_collapseTwo"
                        aria-expanded="false"
                        aria-controls="flush_collapseOne">
                        <span class="group-label"><%=Resources.Global.MyLists %></span>
                    </button>
                </div>
                <div
                    id="flush_collapseTwo"
                    class="accordion-collapse collapse show">

                    <asp:HyperLink ID="hlSavedSearches" runat="server">
                        <button type="button" class="bbs-menu-item">
                            <span class="msicon notranslate">saved_search</span>
                            <div class="text-content">
                                <span class="label"><%=Resources.Global.BrowseSavedSearches %></span>
                            </div>
                        </button>
                    </asp:HyperLink>

                    <asp:HyperLink ID="hlRecentViews" runat="server">
                        <button type="button" class="bbs-menu-item">
                            <span class="msicon notranslate">history</span>
                            <div class="text-content">
                                <span class="label"><%=Resources.Global.RecentViews %></span>
                            </div>
                        </button>
                    </asp:HyperLink>

                    <asp:HyperLink ID="hlLastCompanySearch" runat="server">
                        <button type="button" class="bbs-menu-item">
                            <span class="msicon notranslate">youtube_searched_for</span>
                            <div class="text-content">
                                <span class="label"><%=Resources.Global.RunLastCompanySearch %></span>
                            </div>
                        </button>
                    </asp:HyperLink>
                </div>
            </div>

            <!-- Other Searches -->
            <div class="accordion-item">
                <div class="accordion-header">
                    <button
                        class="accordion-button"
                        type="button"
                        data-bs-toggle="collapse"
                        data-bs-target="#flush_collapseThree"
                        aria-expanded="false"
                        aria-controls="flush_collapseOne">
                        <span class="group-label"><%=Resources.Global.OtherSearches %></span>
                    </button>
                </div>
                <div
                    id="flush_collapseThree"
                    class="accordion-collapse collapse show">

                    <asp:LinkButton ID="hlPersonSearch" runat="server" OnClick="btnPersonSearchOnClick"
                        CssClass="bbs-menu-item">
                    
                        <span class="msicon notranslate">person_search</span>
                        <div class="text-content">
                            <span class="label"><%=Resources.Global.PeopleSearch %></span>
                        </div>
                    </asp:LinkButton>


                    <asp:HyperLink ID="hlCompanyUpdateSearch" runat="server">
                        <button type="button" class="bbs-menu-item">
                            <span class="msicon notranslate">campaign</span>
                            <div class="text-content">
                                <span class="label"><%=Resources.Global.CompanyUpdatesSearch %></span>
                            </div>
                        </button>
                    </asp:HyperLink>

                    <asp:HyperLink ID="hlClaimActivitySearch" runat="server">
                        <button type="button" class="bbs-menu-item">
                            <span class="msicon notranslate">account_balance</span>
                            <div class="text-content">
                                <span class="label"><%=Resources.Global.ClaimSearch %></span>
                            </div>
                        </button>
                    </asp:HyperLink>
                </div>
            </div>

            <button class="bbsButton bbsButton-menu-item full-width"
                id="btnHelp"
                runat="server" type="button"
                data-bs-toggle="tooltip"
                data-bs-placement="right"
                data-bs-title="<%$Resources:Global,Help %>"
                data-bs-custom-class="md:tw-hidden"
                onserverclick="btnHelp_ServerClick">
                <p>
                    <span class="msicon notranslate">help</span>
                    <span class="text-label"><%=Resources.Global.Help %></span>
                </p>
            </button>

        </div>
    </aside>

    <div style="display: none;">
        <asp:Button ID="btnGrowerInclude" CssClass="btn gray_btn" runat="server" />
    </div>

    <asp:HiddenField ID="CheckGrowerIncludeLSS" runat="server" />
    <asp:HiddenField ID="GrowerIncludeLSS" runat="server" />
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        $('.postback').change(function () {
            Update_UpdatePanel();
        });
        $("body").on('DOMSubtreeModified', ".mulSel-tag-container", function () {
            Update_UpdatePanel();
        });

        function Update_UpdatePanel() {
            setHiddenFields();
            $("#contentMain_btnUpdatePanel").click();
        }

        function setHiddenFields() {
            //Location
            $("#<%=hidOtherCountries.ClientID%>").val($("#otherCountries").val());
            setMultiSelHiddenField("countryState-mulSel", "<%=hidSelectedStates.ClientID%>");
            setMultiSelHiddenField("terminalMkt-mulSel", "<%=hidTerminalMarkets.ClientID%>");

            //Commodities
            setMultiSelHiddenField("commodity-mulSel", "<%=hidCommodities.ClientID%>");

            //spot "setHiddenFields"

            //Attributes
            $("#<%=hidAttributes.ClientID%>").val($("#attributes").val());

            //Classifications
            setCheckboxHiddenField("classification", "<%=hidClassifications.ClientID%>");
        }

        function setCheckboxHiddenField(att, hid) {
            var selectedVals = "";
            $("." + att).each(function () {
                if (this.checked) {
                    if (selectedVals)
                        selectedVals += ',';
                    selectedVals += $(this).attr("value");
                }
            });

            $("#" + hid).val(selectedVals);
        }

        function setMultiSelHiddenField(box, hid) {
            var selectedVals = "";
            var field = "data-mulsel_id";
            $("#" + box + " .mulSel-tag-container .bbsButton[" + field + "]").each(function () {
                if (selectedVals)
                    selectedVals += ',';
                selectedVals += $(this).attr(field);
            });

            $("#" + hid).val(selectedVals);
        }

        function clearCriteria(searchPanelType) {
            switch (searchPanelType) {
                case <%=AdvancedCompanySearchBase.SEARCH_PANEL_INDUSTRY%>:
                    break;

                case <%=AdvancedCompanySearchBase.SEARCH_PANEL_COMPANY_DETAILS%>:
                    $("#<%=chkNewListingsOnly.ClientID%>").prop("checked", false);
                    $('#<%=ddlNewListingRange.ClientID%>').val("1");
                    $("#<%=txtCompanyName.ClientID%>").val("");
                    $("#<%=rblCompanyType.ClientID%>").find("input[value='']").prop("checked", true);
                    $('#<%=ddlListingStatus.ClientID%>').val("L,H,LUV"); //listed
                    $("#<%=txtPhoneNumber.ClientID%>").val("");
                    $("#<%=chkPhoneNotNull.ClientID%>").prop("checked", false);
                    $("#<%=txtEmail.ClientID%>").val("");
                    $("#<%=chkEmailNotNull.ClientID%>").prop("checked", false);
                    break;

                case <%=AdvancedCompanySearchBase.SEARCH_PANEL_RATINGS%>:
                    $("#<%=chkTMFMNotNull.ClientID%>").prop("checked", false);
                    $("#<%=txtBBScore.ClientID%>").val("");
                    setCheckboxes('<%=trIntegrityRating.ClientID%>', false);
                    setCheckboxes('<%=trPayDescription.ClientID%>', false);
                    $("#<%=ddlCreditWorthRating_Min.ClientID%>").val("");
                    $("#<%=ddlCreditWorthRating_Max.ClientID%>").val("");
                    break;

                case <%=AdvancedCompanySearchBase.SEARCH_PANEL_LOCATION%>:
                    $("#<%=txtListingCity.ClientID%>").val("");
                    $("#contentMain_radio_country_usa").onchange;
                    mulSel_reset("countryState-mulSel");
                    $("#<%=radio_country_usa.ClientID%>").prop("checked", true);

                    $("#<%=hidSelectedStates.ClientID%>").val("");
                    $("#<%=hidOtherCountries.ClientID%>").val("");
                    $("#<%=hidTerminalMarkets.ClientID%>").val("");
                    $("#<%=txtRadius.ClientID%>").val("");
                    $("#<%=txtZipCode.ClientID%>").val("");

                    $("#contentMain_zipcode_distance").prop("checked", true);

                    mulSel_reset("countryState-mulSel");
                    mulSel_reset("terminalMkt-mulSel");

                    $("#<%=radio_country_usa.ClientID%>").prop("checked", true);
                    $("#<%=radio_country_usa.ClientID%>").onchange;
                    mulSel_createOpt_CountryState('1');
                    mulSel_createOpt_TerminalMkt(terminalMarkets);

                    break;

                case <%=AdvancedCompanySearchBase.SEARCH_PANEL_COMMODITIES%>:
                    $("#<%=hidCommodities.ClientID%>").val("");
                    mulSel_reset("commodity-mulSel");
                    $("#<%=rblGrowingMethod.ClientID%>").find("input[value='0']").prop("checked", true);
                    $("#<%=hidAttributes.ClientID%>").val("");
                    $("#attributes").val("");

                    $("#<%=hidClearCriteria.ClientID%>").val("attributes");
                    break;

                case <%=AdvancedCompanySearchBase.SEARCH_PANEL_CLASSIFICATIONS%>:
                    $("#<%=cbSalvageDistressedProduce.ClientID%>").prop("checked", false);
                    $("#<%=hidClassifications.ClientID%>").val("");
                    $("input[name*='cblNumOfRetail']").prop("checked", false);
                    $("input[name*='cblNumOfRestaurants']").prop("checked", false);

                    clickIfChecked('contentMain_CHK_CLASS1');
                    clickIfChecked('contentMain_CHK_CLASS2');
                    clickIfChecked('contentMain_CHK_CLASS3');
                    clickIfChecked('contentMain_CHK_CLASS4');

                    clickForce('contentMain_rblClassSearchType_0');

                    toggleAllCheckboxes(false, 'cboxes_ProduceBuyer');
                    toggleAllCheckboxes(false, 'cboxes_ProduceSeller');
                    toggleAllCheckboxes(false, 'cboxes_ProduceBroker');
                    toggleAllCheckboxes(false, 'cboxes_SupplyChainServices');
                    break;
                case <%=AdvancedCompanySearchBase.SEARCH_PANEL_LICENSES_CERTS%>:
                    $("#<%=cbOrganic.ClientID%>").prop("checked", false);
                    $("#<%=cbFoodSafety.ClientID%>").prop("checked", false);
                    setCheckboxes('<%=cblLicenseType.ClientID%>', false);
                    $("#<%=txtBrands.ClientID%>").val("");
                    $("#<%=txtMiscListingInfo.ClientID%>").val("");
                    $("#<%=ddlVolume_Min.ClientID%>").val("");
                    $("#<%=ddlVolume_Max.ClientID%>").val("");
                    break;
                case <%=AdvancedCompanySearchBase.SEARCH_PANEL_LOCAL_SOURCE%>:
                    //spot clearCriteria() JavaScript
                    $("#<%=cbOrganic.ClientID%>").prop("checked", false);
                    $("#<%=cbFoodSafety.ClientID%>").prop("checked", false);
                    setCheckboxes('<%=cblLicenseType.ClientID%>', false);
                    $("#<%=txtBrands.ClientID%>").val("");
                    $("#<%=txtMiscListingInfo.ClientID%>").val("");
                    $("#<%=ddlVolume_Min.ClientID%>").val("");
                    $("#<%=ddlVolume_Max.ClientID%>").val("");

                    $("#<%=ddlIncludeLocalSource.ClientID%>").val("");
                    $("input[name*='cblAlsoOperates']").prop("checked", false);
                    $("#<%=cbCertifiedOrganic.ClientID%>").prop("checked", false);
                    $("input[name*='CHK_TOTAL_ACRES']").prop("checked", false);
                    break;
                case <%=AdvancedCompanySearchBase.SEARCH_PANEL_CUSTOM%>:
                    $("#<%=chkCompanyHasNotes.ClientID%>").prop("checked", false);

                    // Clear User List selections
                    bResetUserList = true;
                    $("[id*='repCustomFields_CustomDataField']").val("");
                    $("[id*='repCustomFields_cbCustomDataField']").prop("checked", false);
                    $("input[name='cbUserListID']").prop("checked", false);

                    break;

                case <%=AdvancedCompanySearchBase.SEARCH_PANEL_INTERNAL%>:
                    setCheckboxes('<%=cblSalesTerritory.ClientID%>', false);
                    $("#<%=ddlTerritoryCode.ClientID%>").val("");
                    $("#<%=ddlMembershipTypeCode.ClientID%>").val("");
                    setCheckboxes('<%=cblPrimaryService.ClientID%>', false);

                    $("#<%=txtAvailLicense.ClientID%>").val("");
                    $("#<%=txtActiveLicense.ClientID%>").val("");
                    $("#<%=txtAvailableUnits.ClientID%>").val("");
                    $("#<%=txtUsedUnits.ClientID%>").val("");
                    $("#<%=txtMembershipRevenue.ClientID%>").val("");
                    $("#<%=txtAdvertisingRevenue.ClientID%>").val("");

                    $("#<%=cbReceivesPromoFaxes.ClientID%>").prop("checked", false);
                    $("#<%=cbReceivesPromoEmails.ClientID%>").prop("checked", false);
                    break;
            }

            //Spot clearCriteria() clientside
        }

        function setCheckboxes(pID, checked) {
            $("#" + pID).find(":checkbox").prop("checked", checked);
        }

        function pageLoad() {
            runOnce();
        }

        function runOnce() {
            //Spot runOnce()
            if ($("#<%=hidPostback.ClientID %>").val() == '') {
                mulSel_createOpt_TerminalMkt(terminalMarkets);
                mulSel_createOpt_Commodities(); 
            }
            $("#<%=hidPostback.ClientID %>").val('done');
        }

        btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');
        togglePrimaryService();

        function initPageDisplay() {
            var $currentElem;
            $('#contentMain_pnlProduceClass').find('input:hidden').each(function () {
                $currentElem = $(this)[0];
                var szPnl = $currentElem.id.substring(15); //remove prefix
                //Set_Hid_Display(szPnl, $currentElem);
            });
        }

        function processCheck(child) {
            disableParent(child);
            displayNumofRetail();
        }

        function disableParent(child) {
            if (!child.checked) {
                document.getElementById('contentMain_' + child.attributes['parentid'].value).checked = false;
            }
        }

        function displayNumofRetail() {
            var ret = false;
            var rest = false;

            $(".classification").each(function () {
                if ($(this).is(":checked")) {
                    if ($(this).val() == "<%=CLASSIFICATION_ID_RESTAURANT%>") rest = true;
                    else if ($(this).val() == "<%=CLASSIFICATION_ID_RETAIL%>") ret = true;
                    else if ($(this).val() == "<%=CLASSIFICATION_ID_RETAIL_YARD_DEALER%>") ret = true;
                }
            });

            if (ret || rest)
                $("#pnlNumberOfStores").removeClass("tw-hidden");
            else
                $("#pnlNumberOfStores").addClass("tw-hidden");

            if (ret)
                $("#<%=fsNumOfRetail.ClientID%>").removeAttr("disabled");
            else
                $("#<%=fsNumOfRetail.ClientID%>").attr("disabled", "disabled");

            if (rest)
                $("#<%=fsNumOfRestaurant.ClientID%>").removeAttr("disabled");
            else
                $("#<%=fsNumOfRestaurant.ClientID%>").attr("disabled", "disabled");
        }

        function refreshCriteria() {
            <%=ClientScript.GetPostBackEventReference(UpdatePanel1, "")%>;
        }

        function togglePrimaryService() {
            var disabled = true;
            var e = document.getElementById("contentMain_ddlMembershipTypeCode");
            if (e != null && e.options[e.selectedIndex].value == "M") {
                disabled = false;
            }

            for (i = 0; i < document.forms[0].elements.length; i++) {
                if (document.forms[0].elements[i].id.indexOf("<%= cblPrimaryService.ClientID %>") == 0) {
                    document.forms[0].elements[i].disabled = disabled;
                }
            }
        }

        function refreshTerminalMarkets() {
            var filterStates = [];
            var filterStatesExcluded = [];

            if (getSelectedCountry2() == '1') {
                filterStatesExcluded.push('MX');
            }
            if (getSelectedCountry2() == '2') {
                mulSel_createOpt_TerminalMkt([]);
                return;
            }
            else if (getSelectedCountry2() == '3') {
                filterStates.push('MX');
            }

            if (hidSelectedStates.value) {
                var states_selected = <%=hidSelectedStates.ClientID%>.value.split(',');
                
                for (var i = 0; i < states_selected.length; i++) {
                    // Trim the excess whitespace.
                    states_selected[i] = states_selected[i].replace(/^\s*/, "").replace(/\s*$/, "");

                    let curState = states.find(s => s.prst_StateId === states_selected[i]);
                    filterStates.push(curState.prst_Abbreviation);
                }
            }

            var filteredTerminalMarkets = [];

            // initialize array
            if (filterStates.length > 0) {
                filteredTerminalMarkets = terminalMarkets.filter(function (e) {
                    return filterStates.includes(e.prtm_State) && !filterStatesExcluded.includes(e.prtm_State);
                });
            }
            else {
                filteredTerminalMarkets = terminalMarkets.filter(function (e) {
                    return !filterStatesExcluded.includes(e.prtm_State);
                });
            }

            mulSel_createOpt_TerminalMkt(filteredTerminalMarkets);
        }

        Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(initPageDisplay);
    </script>
</asp:Content>
