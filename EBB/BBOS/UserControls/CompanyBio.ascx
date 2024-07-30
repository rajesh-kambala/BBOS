<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CompanyBio.ascx.cs" Inherits="PRCo.BBOS.UI.Web.UserControls.CompanyBio" %>

<%--<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>--%>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Import Namespace="PRCo.EBB.BusinessObjects" %>

<section class="company-bio">
    <div class="tw-flex tw-flex-col tw-gap-2">
        <div class="tw-flex">
            <!-- Tags, Name and address -->
            <div class="tw-flex tw-grow tw-flex-col tw-gap-2">
                <div class="company-tags">
                    <div class="tag green">
                        <span runat="server" id="litIndustryIcon" class="msicon notranslate">temp_preferences_eco</span>
                        <span>
                            <asp:Literal ID="litIndustry" runat="server" /></span>
                    </div>

                    <div class="vr"></div>

                    <asp:Repeater ID="repClassificationsLevel1" runat="server">
                        <ItemTemplate>
                            <div class="tag">
                                <span><%# DataBinder.Eval(Container.DataItem, "Level1") %></span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <h3>
                    <asp:Literal ID="litCompanyName" runat="server" />
                </h3>
                <div class="tag red" ID="ListingpendingVerificationTag" runat="server" visible="false">
                    <span class="msicon notranslate">gpp_maybe</span>
                    <span><asp:Literal runat="server" Text="<%$Resources:Global, ListingVerificationPending%>" /></span>
                  </div>

                <p class="company-address">
                    <span class="msicon notranslate">location_on</span>
                    <asp:Literal ID="litLocation" runat="server" />
                </p>
                <div class="company-phone">
                    <p>
                        <span class="msicon notranslate">link</span>
                        <asp:HyperLink ID="hlWebsite" Target="_blank" runat="server" Text="<%$Resources:Global,WebsiteNotAvailable %>" NavigateUrl="#" Enabled="false" />
                    </p>
                    <p>
                        <span class="msicon notranslate">email</span>
                        <asp:HyperLink ID="hlEmail" Target="_blank" runat="server" Text="<%$Resources:Global,EmailAddressNotAvailable %>" NavigateUrl="#" Enabled="false" />
                    </p>
                    <p>
                        <span class="msicon notranslate">phone</span>
                        <asp:Literal ID="litPhone" runat="server" />
                    </p>
                    <p>
                        <span class="msicon notranslate">event_available</span>
                        <asp:Literal ID="litBusinessStartDateStateTitle" runat="server" Text="<%$Resources:Global, BusinessStartDate%>" />
                        :
                <asp:Literal ID="litBusinessStartDate" runat="server" />
                    </p>
                </div>
            </div>
            <!-- trading seals -->
            <div class="tw-flex tw-flex-col tw-items-center tw-text-center tw-gap-2" id="trTMFM" runat="server">
                <asp:Image ID="imgTMFM" runat="server" Visible="false" Width="100px" Height="100px"
                    data-bs-toggle="tooltip"
                    data-bs-placement="left"
                    data-bs-html="true"
                    data-bs-title="<%$Resources:Global,TradingSealTooltip %>" />
                <p class="text-xxs tw-text-text-secondary">
                    <asp:Label ID="lblTMFMMsg" runat="server" />
                </p>
            </div>
        </div>

    </div>
    <div class="tw-flex tw-flex-wrap tw-gap-x-6 tw-gap-y-2">
        <p class="text-sm tw-flex-grow tw-text-text-secondary">
            <%=Resources.Global.BlueBookNumber %><asp:Literal ID="litBBID" runat="server"></asp:Literal>
        </p>

        <div class="tw-flex tw-gap-2 tw-flex-wrap">
            <button type="button"
                class="bbsButton bbsButton-tag-secondary square notes"
                data-bs-toggle="tooltip"
                data-bs-title="<%$Resources:Global,ViewNotes %>"
                id="btnNotes" runat="server" visible="false" onserverclick="btnNotes_ServerClick">
                <span class="msicon notranslate">note_stack</span>
                <span><%=Resources.Global.Notes %>&nbsp;(<asp:Literal ID="litNoteCount" runat="server" />)</span>
            </button>


            <button type="button"
                class="bbsButton bbsButton-tag-secondary square changed"
                data-bs-toggle="tooltip"
                data-bs-title=""
                id="btnChanged" runat="server" visible="false" onserverclick="btnChanged_ServerClick">
                <span class="msicon notranslate">lightbulb</span>
                <span><%=Resources.Global.Changed %></span>
            </button>

            <!--  watchdog Modal -->
            <div class="modal fade" id="watchdogModal" tabindex="-1" aria-labelledby="watchdogModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h1 class="modal-title fs-5" id="watchdogModalLabel"><%=Resources.Global.Watchdog %></h1>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <asp:Repeater ID="repCategories" runat="server">
                                <HeaderTemplate>
                                    <ul class="list-group">
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <li class="list-group-item">
                                        <div class="tw-flex tw-gap-2"><%# PageControlBaseCommon.GetCategoryIcon(Eval("prwucl_CategoryIcon"), Eval("prwucl_Name"))%> <%# Eval("prwucl_Name") %></div>
                                    </li>
                                </ItemTemplate>
                                <FooterTemplate>
                                    </ul>
                                </FooterTemplate>
                            </asp:Repeater>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="bbsButton bbsButton-secondary" data-bs-dismiss="modal"><%=Resources.Global.Close %></button>
                            <button type="button"
                                class="bbsButton bbsButton-primary"
                                id="btnWatchdog1" runat="server" onserverclick="btnWatchdog_ServerClick">
                                <span class="msicon notranslate">sound_detection_dog_barking</span>
                                <span><%=Resources.Global.Open %>&nbsp;<%=Resources.Global.Watchdog %></span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Watchdog button -->
            <button type="button"
                class="bbsButton bbsButton-tag-secondary square watchdog"
                id="btnWatchdog" runat="server" visible="false"
                data-bs-toggle="modal"
                data-bs-target="#watchdogModal">
                <span class="msicon notranslate">sound_detection_dog_barking</span>
                <span><%=Resources.Global.Watchdog %>&nbsp;(<asp:Literal ID="watchdogCount" runat="server" />)</span>
            </button>

            <button type="button"
                class="bbsButton bbsButton-tag-secondary square new"
                data-bs-toggle="tooltip"
                data-bs-title=""
                id="btnNew" runat="server" visible="false" onserverclick="btnNew_ServerClick">
                <span class="msicon notranslate">temp_preferences_custom</span>
                <span><%=Resources.Global.New %></span>
            </button>
            <a href="#businessdetails">
                <button type="button"
                    class="bbsButton bbsButton-tag-secondary square organic"
                    data-bs-toggle="tooltip"
                    data-bs-title=""
                    id="btnCertified" runat="server" visible="false">
                    <span class="msicon notranslate">verified</span>
                    <span><%=Resources.Global.Certified %></span>
                </button>
            </a>
            <button type="button"
                class="bbsButton bbsButton-tag-secondary square new"
                data-bs-toggle="tooltip"
                data-bs-title="<%$Resources:Global,NewClaimReported%>"
                id="btnNewClaim" runat="server" visible="false" onserverclick="btnNewClaim_ServerClick">
                <span class="msicon notranslate">account_balance</span>
                <span><%=Resources.Global.NewClaim %></span>
            </button>
        </div>
    </div>
    <p id="trMessage" runat="server" class="text-left mar_top bold" visible="false">
        <asp:Label class="MsgHightlight" ID="litMessage" runat="server" /><br />
    </p>
</section>
