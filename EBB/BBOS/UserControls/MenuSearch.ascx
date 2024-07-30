<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="MenuSearch.ascx.cs" Inherits="PRCo.BBOS.UI.Web.UserControls.MenuSearch" %>

<div class="left-sidebar">
    <p class="group-label">Advanced Company Search</p>

    <button
        class="bbsButton bbsButton-menu-item full-width selected"
        data-bs-toggle="tooltip"
        data-bs-placement="right"
        data-bs-title="Produce Search"
        data-bs-custom-class="md:tw-hidden">
        <p>
            <span class="msicon notranslate">psychiatry</span>
            <span class="text-label">Produce</span>
            <span class="bbsBadge">New</span>
        </p>
    </button>
    <button
        class="bbsButton bbsButton-menu-item full-width"
        data-bs-toggle="tooltip"
        data-bs-placement="right"
        data-bs-title="Transport Search"
        data-bs-custom-class="md:tw-hidden">
        <p>
            <span class="msicon notranslate">local_shipping</span>
            <span class="text-label">Transport</span>
        </p>
    </button>
    <button
        class="bbsButton bbsButton-menu-item full-width"
        data-bs-toggle="tooltip"
        data-bs-placement="right"
        data-bs-title="Supply Search"
        data-bs-custom-class="md:tw-hidden">
        <p>
            <span class="msicon notranslate">conveyor_belt</span>
            <span class="text-label">Supply</span>
        </p>
    </button>
    <hr />
    <p class="group-label">My Lists</p>

    <asp:LinkButton type="button" ID="hlSavedSearches" runat="server"
        CssClass="bbsButton bbsButton-menu-item full-width"
        data-bs-toggle="tooltip"
        data-bs-placement="right"
        data-bs-title="<%#Resources.Global.BrowseSavedSearches %>"
        data-bs-custom-class="md:tw-hidden" 
        >
                <p>
                    <span class="msicon notranslate">saved_search</span>
                    <span class="text-label"><% =Resources.Global.BrowseSavedSearches%></span>
                </p>
    </asp:LinkButton>

    <asp:LinkButton type="button" ID="hlRecentViews" runat="server"
        CssClass="bbsButton bbsButton-menu-item full-width"
        data-bs-toggle="tooltip"
        data-bs-placement="right"
        data-bs-title="<%#Resources.Global.RecentViews %>"
        data-bs-custom-class="md:tw-hidden">
                <p>
                    <span class="msicon notranslate">saved_search</span>
                    <span class="text-label"><% =Resources.Global.RecentViews%></span>
                </p>
    </asp:LinkButton>

    <asp:LinkButton type="button" ID="hlLastCompanySearch" runat="server"
        CssClass="bbsButton bbsButton-menu-item full-width"
        data-bs-toggle="tooltip"
        data-bs-placement="right"
        data-bs-title="<%#Resources.Global.RunLastSearch %>"
        data-bs-custom-class="md:tw-hidden">
                <p>
                    <span class="msicon notranslate">youtube_searched_for</span>
                    <span class="text-label"><% =Resources.Global.RunLastSearch%></span>
                </p>
    </asp:LinkButton>

    <hr />

    <p class="group-label">Other Searches</p>

    <asp:LinkButton type="button" ID="hlPersonSearch" runat="server"
        CssClass="bbsButton bbsButton-menu-item full-width"
        data-bs-toggle="tooltip"
        data-bs-placement="right"
        data-bs-title="<%#Resources.Global.PeopleSearch %>"
        data-bs-custom-class="md:tw-hidden">
                <p>
                    <span class="msicon notranslate">person_search</span>
                    <span class="text-label"><% =Resources.Global.PeopleSearch%></span>
                </p>
    </asp:LinkButton>

    <asp:LinkButton type="button" ID="hlCompanyUpdateSearch" runat="server"
        CssClass="bbsButton bbsButton-menu-item full-width"
        data-bs-toggle="tooltip"
        data-bs-placement="right"
        data-bs-title="<%#Resources.Global.CompanyUpdatesSearch %>"
        data-bs-custom-class="md:tw-hidden">
                <p>
                    <span class="msicon notranslate">work_history</span>
                    <span class="text-label"><% =Resources.Global.CompanyUpdatesSearch%></span>
                </p>
    </asp:LinkButton>

    <asp:LinkButton type="button" ID="hlClaimActivitySearch" runat="server"
        CssClass="bbsButton bbsButton-menu-item full-width"
        data-bs-toggle="tooltip"
        data-bs-placement="right"
        data-bs-title="<%#Resources.Global.ClaimSearch %>"
        data-bs-custom-class="md:tw-hidden">
                <p>
                    <span class="msicon notranslate">universal_currency_alt</span>
                    <span class="text-label"><% =Resources.Global.ClaimSearch%></span>
                </p>
    </asp:LinkButton>

    <hr />

    <button
        class="bbsButton bbsButton-menu-item full-width"
        data-bs-toggle="tooltip"
        data-bs-placement="right"
        data-bs-title="help"
        data-bs-custom-class="md:tw-hidden"
        onclick="bbAlert('TODO:BBOS Where should this navigate to?'); return false;">
        <p>
            <span class="msicon notranslate">help</span>
            <span class="text-label">Help</span>
        </p>
    </button>
</div>