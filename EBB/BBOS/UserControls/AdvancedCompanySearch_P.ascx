<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AdvancedCompanySearch_P.ascx.cs" Inherits="PRCo.BBOS.UI.Web.AdvancedCompanySearch_P" %>

<div class="search-form tw-max-w-[400px]">
    <h2><%= Resources.Global.SearchProduceCompanies %></h2>
    <div class="bbs-accordion">
        <div class="bbs-accordion-item">
            <button onclick="toggleAccordion(event)"
                type="button"
                class="bbs-accordion-header">
                <div>
                    <span class="msicon notranslate expand-icon">expand_more</span>
                </div>
                <div class="label">
                    <span class="text-label"><%=Resources.Global.ACCORDION_HEADER_COMPANY_DETAILS %></span>
                    <span class="caption"><%=Resources.Global.ACCORDION_HEADER_COMPANY_DETAILS_SUBTEXT %>
                    </span>
                </div>
            </button>
            <div class="bbs-accordion-content">
                <div class="content-wrapper tw-flex tw-flex-col tw-gap-4">
                    <div class="input-wrapper">
                        <label for="txtCompanyName"><%=Resources.Global.CompanyName %></label>
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
                        <asp:RadioButtonList ID="rblCompanyType" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="bbs-radio-input postback" />
                    </div>

                    <div class="input-wrapper">
                        <p class="label">
                            <span><%=Resources.Global.RejectedShipments %></span>
                            <span
                                class="msicon notranslate help"
                                tabindex="0"
                                data-bs-toggle="tooltip"
                                data-bs-placement="right"
                                data-bs-html="true"
                                data-bs-title="<%=Resources.Global.ShowCompaniesThatTakeRejectedShipments %>">help
                            </span>
                        </p>
                        <div class="bbs-checkbox-input">
                            <input type="checkbox" id="chkHandlesRejectedShipments" runat="server" class="postback">
                            <label for="<%=chkHandlesRejectedShipments.ClientID%>"><%=Resources.Global.HandlesRejectedShipments %></label>
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
                        <div class="bbs-checkbox-input">
                            <input type="checkbox" id="chkPhoneNotNull" runat="server" class="postback">
                            <label for="<%=chkPhoneNotNull.ClientID%>"><%=Resources.Global.MustHaveAPhoneNumber %></label>
                        </div>


                        <p class="caption">
                            <%=Resources.Global.LeavePhoneNumberEmptyForAnyNumber %>
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
                </div>
            </div>
        </div>

        <%--TODO:JMT resource translate and move other accordians (below) into user controls as needed--%>
        <div class="bbs-accordion-item open">
            <button onclick="toggleAccordion(event)"
                type="button"
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
                <div class="content-wrapper tw-flex tw-flex-col tw-gap-4">
                    <div data-info="Trading checkbox" class="input-wrapper">
                        <div class="bbs-checkbox-input">
                            <input type="checkbox" id="chkTMFMNotNull" runat="server" class="postback">
                            <label for="<%=chkTMFMNotNull.ClientID%>"><%=Resources.Global.TradingTransportationMembersOnly %></label>
                        </div>
                    </div>
                    <div data-info="Blue Book Score" class="input-wrapper">
                        <label for="companyemail"><%=Resources.Global.BlueBookScore %></label>
                        <p class="tw-flex tw-gap-4">
                            <asp:DropDownList ID="ddlBBScoreSearchType" runat="server" CssClass="postback" />
                             <asp:TextBox ID="txtBBScore"
                                CssClass="full-width postback"
                                type="text"
                                runat="server" />
                        </p>
                    </div>
                    <div data-info="Trade Practices">
                        <p class="label tw-mb-2">Trade Practices</p>
                        <div class="tw-grid tw-grid-cols-2 tw-gap-x-4">
                            <div class="bbs-checkbox-input">
                                <input type="checkbox" id="XXXX" />
                                <label for="XXXX">XXXX - Excellent</label>
                            </div>
                            <div class="bbs-checkbox-input">
                                <input type="checkbox" id="XX" />
                                <label for="XX">XX - Unsatisfactory</label>
                            </div>

                            <div class="bbs-checkbox-input">
                                <input type="checkbox" id="XXX" />
                                <label for="XXX">XXX - Good</label>
                            </div>
                            <div class="bbs-checkbox-input">
                                <input type="checkbox" id="X" />
                                <label for="X">X - Poor</label>
                            </div>
                        </div>
                    </div>
                    <hr />
                    <div data-info="Pay Description">
                        <p class="label tw-mb-2">Pay Description</p>
                        <div class="tw-grid tw-grid-cols-2 tw-gap-x-4">
                            <div class="bbs-checkbox-input">
                                <input type="checkbox" id="AA" />
                                <label for="AA">AA - 1 - 14 days on average</label>
                            </div>
                            <div class="bbs-checkbox-input">
                                <input type="checkbox" id="D" />
                                <label for="D">D - 36 - 45 days on average</label>
                            </div>
                            <div class="bbs-checkbox-input">
                                <input type="checkbox" id="A" />
                                <label for="A">A - 15-21 days on average</label>
                            </div>
                            <div class="bbs-checkbox-input">
                                <input type="checkbox" id="E" />
                                <label for="E">E - 46 - 60 days on average</label>
                            </div>
                            <div class="bbs-checkbox-input">
                                <input type="checkbox" id="B" />
                                <label for="B">B - 22 - 28 days on average</label>
                            </div>
                            <div class="bbs-checkbox-input">
                                <input type="checkbox" id="F" />
                                <label for="F">F - 60+ days on average</label>
                            </div>
                            <div class="bbs-checkbox-input">
                                <input type="checkbox" id="C" />
                                <label for="C">C - 29 - 35 days on average</label>
                            </div>
                        </div>
                    </div>
                    <hr />
                    <div data-info="Credit Worth Rating">
                        <p class="label">
                            Credit Worth Rating
                          <span
                              class="msicon notranslate help"
                              tabindex="0"
                              data-bs-toggle="tooltip"
                              data-bs-placement="right"
                              data-bs-html="true"
                              data-bs-title="M = thousand">help
                          </span>
                        </p>

                        <div class="tw-grid tw-grid-cols-2 tw-gap-x-4">
                            <div
                                data-info="Blue Book Score"
                                class="input-wrapper">
                                <label for="min-score">Min</label>

                                <select
                                    id="min-score"
                                    aria-label="Small select example">
                                    <option value="1">-M (min)</option>
                                </select>
                            </div>
                            <div
                                data-info="Blue Book Score"
                                class="input-wrapper">
                                <label for="max-score">Max</label>

                                <select
                                    id="max-score"
                                    aria-label="Small select example">
                                    <option value="1">500,000M (max)</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="bbs-accordion-item">
            <button onclick="toggleAccordion(event)"
                type="button"
                class="bbs-accordion-header">
                <div>
                    <span class="msicon notranslate expand-icon">expand_more</span>
                </div>
                <div class="label">
                    <span class="text-label">Location</span>
                    <span class="caption">State, city or zip (US) or other countries or distance
                                                (US only)
                    </span>
                </div>
            </button>
            <div class="bbs-accordion-content">
                <div class="content-wrapper tw-opacity-50">
                    <img src="assets/there_is_nothing_here.svg" />
                    <span>THERE IS NOTHING HERE</span>
                </div>
            </div>
        </div>
        <div class="bbs-accordion-item">
            <button onclick="toggleAccordion(event)"
                type="button"
                class="bbs-accordion-header">
                <div>
                    <span class="msicon notranslate expand-icon">expand_more</span>
                </div>
                <div class="label">
                    <span class="text-label">Commodities</span>
                    <span class="caption">Types of fruits, vegetables, etc
                    </span>
                </div>
            </button>
            <div class="bbs-accordion-content">
                <div class="content-wrapper tw-opacity-50">
                    <img src="assets/there_is_nothing_here.svg" />
                    <span>THERE IS NOTHING HERE</span>
                </div>
            </div>
        </div>
        <div class="bbs-accordion-item">
            <button onclick="toggleAccordion(event)"
                type="button"
                class="bbs-accordion-header">
                <div>
                    <span class="msicon notranslate expand-icon">expand_more</span>
                </div>
                <div class="label">
                    <span class="text-label">Classification</span>
                    <span class="caption">Industry supplier or type of service
                    </span>
                </div>
            </button>
            <div class="bbs-accordion-content">
                <div class="content-wrapper tw-opacity-50">
                    <img src="assets/there_is_nothing_here.svg" />
                    <span>THERE IS NOTHING HERE</span>
                </div>
            </div>
        </div>
        <div class="bbs-accordion-item">
            <button onclick="toggleAccordion(event)"
                type="button"
                class="bbs-accordion-header">
                <div>
                    <span class="msicon notranslate expand-icon">expand_more</span>
                </div>
                <div class="label">
                    <span class="text-label">Licenses and Certifications</span>
                    <span class="caption">Volume, Licenses or certifications
                    </span>
                </div>
            </button>
            <div class="bbs-accordion-content">
                <div class="content-wrapper tw-opacity-50">
                    <img src="assets/there_is_nothing_here.svg" />
                    <span>THERE IS NOTHING HERE</span>
                </div>
            </div>
        </div>
        <div class="bbs-accordion-item">
            <button onclick="toggleAccordion(event)"
                type="button"
                class="bbs-accordion-header">
                <div>
                    <span class="msicon notranslate expand-icon">expand_more</span>
                </div>
                <div class="label">
                    <span class="text-label">Other Details</span>
                    <span class="caption">Blue book member or other information
                    </span>
                </div>
            </button>
            <div class="bbs-accordion-content">
                <div class="content-wrapper tw-opacity-50">
                    <img src="assets/there_is_nothing_here.svg" />
                    <span>THERE IS NOTHING HERE</span>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    $('.postback').change(function () {
        Update_UpdatePanel();
    });

    function Update_UpdatePanel() {
        $("#contentMain_btnUpdatePanel").click();
    }
</script>
