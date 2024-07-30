<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanySearchResults.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanySearchResults" EnableEventValidation="false" EnableViewStateMac="false" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="bbos" TagName="Advertisements" Src="UserControls/Advertisements.ascx" %>
<%@ Register Src="UserControls/AdvancedCompanySearchCriteriaControl.ascx" TagName="AdvancedCompanySearchCriteriaControl" TagPrefix="uc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
  <link rel="stylesheet" href="Content/ideal-image-slider.css" />
  <link rel="stylesheet" href="Content/ideal-image-slider_default.css" />

  <style>
    #slider {
      max-width: 1150px;
      margin: 15px auto;
    }
  </style>
  <script type="text/javascript">
    function processResults() {
      setTimeout("displayZeroResults();", 500);
    }

    function displayZeroResults() {
      var mpeZeroResults = $find('mpeZeroResults');
      if (mpeZeroResults != null) {
        mpeZeroResults.show();
      } else {
        setTimeout("displayZeroResults();", 500);
      }
    }

    function submitFeedback() {
      document.location.href = "Feedback.aspx?FeedbackType=RULC";
    }

    function toggleDisplayZeroResults(eCheckbox) {
      var today = new Date();
      today.setTime(today.getTime());
      expires = 1000 * 60 * 15;  // 15 minutes
      var expires_date = new Date(today.getTime() + (expires));


      if (eCheckbox.checked) {
        document.cookie = "displayZeroResults=Y;expires=" + expires_date.toGMTString();
      } else {
        document.cookie = "displayZeroResults=N;expires=" + expires_date.toGMTString();
      }
    }

    var imgPlus = 'images/collapsed.gif';
    var imgMinus = 'images/expanded.gif';
  </script>

  <script type="text/javascript" src="en-us/javascript/toggleFunctions.min.js"></script>
  <script type="text/javascript" src="Scripts/print.min.js"></script>
  <style>
    .main-content-old {
      width: 100%;
      padding: 16px;
    }
  </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <!-- Show the selected search criteria in the bootstrap offcanvas -->
    <div
        class="offcanvas offcanvas-end search-criteria-offcanvas"
        tabindex="-1"
        id="offcanvasRight"
        aria-labelledby="Search criteria">
        <div class="offcanvas-header">
        <div class="tw-flex tw-w-full tw-justify-between">
            <div class="tw-flex tw-items-center">
            <button
                type="button"
                class="bbsButton bbsButton-tertiary"
                data-bs-dismiss="offcanvas"
                aria-label="Close">
                <span class="msicon notranslate">clear</span>
            </button>
            <h5
                class="offcanvas-title title"
                id="offcanvasRightLabel">
                <%=Resources.Global.SearchCriteria %>
            </h5>
            </div>
            <div class="tw-flex tw-gap-3">
            <button id="btnEditSearchCriteria2" runat="server" type="button" class="bbsButton bbsButton-secondary" onserverclick="btnEditSearchCriteria_Click">
                <span class="msicon notranslate">arrow_back</span>
                <span><%=Resources.Global.BackToEditSearch %></span>
            </button>

            <button id="btnSaveSearch2" runat="server" type="button" class="bbsButton bbsButton-primary filled tw-w-full" onserverclick="btnSaveSearch_Click">
                <span class="msicon notranslate">saved_search</span>
                <span><%=Resources.Global.SaveSearch %></span>
            </button>
            </div>
        </div>
        </div>

        <%--Search Criteria--%>
        <div class="offcanvas-body">
        <uc1:AdvancedCompanySearchCriteriaControl ID="ucAdvancedCompanySearchCriteriaControl" runat="server" IncludeClearButton="false" />
        </div>
    </div>

  <div id="slider" class="hidden">
    <asp:Literal ID="microslider" runat="server" />
  </div>

  <div class="tw-flex tw-flex-wrap tw-gap-2 tw-justify-end tw-bg-bg-secondary tw-border-border tw-sticky p-3 border-bottom" style="top: 43px;z-index: 1;">
    <div class="tw-flex tw-w-full tw-flex-wrap tw-justify-end tw-gap-3 tw-px-3">
      <button id="btnEditSearchCriteria" runat="server" type="button" class="bbsButton bbsButton-secondary filled max-sm:full-width" onserverclick="btnEditSearchCriteria_Click">
        <span class="msicon notranslate">arrow_back</span>
        <span><%=Resources.Global.BackToEditSearch %></span>
      </button>

      <button id="btnSaveSearch" runat="server" type="button" class="bbsButton bbsButton-secondary filled max-sm:full-width" onserverclick="btnSaveSearch_Click">
        <span class="msicon notranslate">saved_search</span>
        <span><%=Resources.Global.SaveSearch %></span>
      </button>

      <button
        type="button"
        data-bs-toggle="offcanvas"
        data-bs-target="#offcanvasRight"
        aria-controls="offcanvasRight"
        class="bbsButton bbsButton-secondary filled max-sm:full-width">
        <span class="msicon notranslate">manage_search</span>
        <span><%=Resources.Global.ShowSearchCriteria %></span>
      </button>
    </div>
  </div>

  <div class="tw-grid tw-grid-cols-12 tw-gap-3">
    <div class="tw-col-span-12 md:tw-col-span-10">
      <%-- Seach Results Table --%>
      <div class="bbs-card-bordered">
        <div class="bbs-card-header">
          <%--Record Count--%>
          <p class="caption tw-my-2 tw-px-3">
            <asp:Label ID="lblRecordCount" runat="server" />&nbsp;|&nbsp;<span id="lblSelectedCount"></span>
          </p>

          <%-- LocalSource alert --%>
          <asp:Panel ID="pnlLocalSourceMsg" CssClass="bbs-alert alert-info tw-my-4" Visible="false" runat="server">
            <div class="alert-title">
              <span class="msicon notranslate">info</span>
              <span>
                <%=Resources.Global.DidYouKnowThat1 %>
                <asp:Literal ID="litLocalSourceCount" runat="server" />
                <%=Resources.Global.DidYouKnowThat2 %>
              </span>
            </div>
          </asp:Panel>

          <%-- Table buttons --%>
          <div class="tw-flex tw-justify-end tw-gap-2 tw-flex-col lg:tw-flex-row tw-px-3 tw-w-full">

            <div class="bbsButtonGroup rounded tw-w-fit">
              <%--Print List--%>

              <button id="btnReports" runat="server" type="button" class="bbsButton bbsButton-secondary filled" onserverclick="btnReports_Click" title="<%$Resources:Global,btnPrintList %>">
                <span class="msicon notranslate">local_printshop</span>
              </button>
              <button id="btnPrintList" runat="server" type="button" class="bbsButton bbsButton-secondary filled" onclick="printList(); return false;" visible="false" title="<%$Resources:Global, btnPrintList %>">
                <span class="msicon notranslate">local_printshop</span>
              </button>

              <button id="btnMap" runat="server" class="bbsButton bbsButton-secondary filled" type="button" onclick="displayMap();return false;" title="<%$Resources:Global, btnShowOnMap %>">
                <span class="msicon notranslate">location_pin</span>
              </button>

              <button id="btnAddToWatchdog" runat="server" type="button" class="bbsButton bbsButton-secondary filled" onserverclick="btnAddToWatchdog_Click" title="<%$Resources:Global, btnAddToWatchdogList %>">
                <span class="msicon notranslate">sound_detection_dog_barking
                </span>
              </button>

              <button id="btnCustomFieldEdit" runat="server" type="button" class="bbsButton bbsButton-secondary filled" onserverclick="btnCustomFieldEdit_Click" title="<%$Resources:Global, btnEditCustomData %>">
                <span class="msicon notranslate">mode_edit_outline</span>
              </button>
            </div>

            <div class="bbsButtonGroup tw-grow">
              <button id="btnSubmitTES" runat="server" type="button" class="bbsButton bbsButton-secondary full-width filled" onserverclick="btnSubmitTESOnClick" title="<%$Resources:Global, RateCompany %>">
                <span class="msicon notranslate">thumb_up_off_alt</span>
                <span><%=Resources.Global.RateCompany %></span>
              </button>

              <button id="btnAnalyzeCompanies" runat="server" type="button" class="bbsButton bbsButton-secondary full-width filled" onserverclick="btnAnalyzeCompanies_Click" title="<%$Resources:Global, btnAnalyzeCompanies %>">
                <span class="msicon notranslate">frame_inspect</span>
                <span><%=Resources.Global.btnAnalyzeCompanies %></span>
              </button>

              <button id="btnExportData" runat="server" type="button" class="bbsButton bbsButton-secondary full-width filled" onserverclick="btnExportData_Click" onclick="if(!confirmSelect('Company','cbCompanyID') || !ValidateExportsCount()) return false;">
                <span class="msicon notranslate">export_notes</span>
                <span><%=Resources.Global.btnExportData %></span>
              </button>
            </div>
          </div>


          <asp:HiddenField ID="hidSelectedCount" runat="server" Value="0" />
          <asp:HiddenField ID="hidExportsMax" runat="server" Value="0" />
          <asp:HiddenField ID="hidExportsUsed" runat="server" Value="0" />
          <asp:HiddenField ID="hidExportsPeriod" runat="server" Value="M" />

        </div>
        <div class="bbs-card-body no-padding">
          <div class="table-responsive" id="SearchResults_PrintDiv">
            <asp:GridView ID="gvSearchResults"
              AllowSorting="true"
              runat="server"
              AutoGenerateColumns="false"
              CssClass=" table  table-hover"
              GridLines="None"
              OnSorting="GridView_Sorting"
              OnRowDataBound="GridView_RowDataBound"
              SortField="comp_PRBookTradestyle"
              DataKeyNames="comp_CompanyID">

              <Columns>
                <asp:TemplateField ItemStyle-CssClass="text-center vertical-align-top" HeaderStyle-CssClass="text-center vertical-align-top">
                  <HeaderTemplate>
                    <!--% =Resources.Global.Select%-->
                    <!--br /-->
                    <% =PageBase.GetCheckAllCheckbox("cbCompanyID", "setSelectedCount();")%>
                  </HeaderTemplate>
                  <ItemTemplate>
                    <input type="checkbox" name="cbCompanyID" value="<%# Eval("comp_CompanyID") %>" <%# GetChecked((int)Eval("comp_CompanyID")) %> onclick="setSelectedCount();" />
                  </ItemTemplate>
                </asp:TemplateField>

                <%--BBNumber Column--%>
                <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left" DataField="comp_CompanyID" SortExpression="comp_CompanyID" />

                <%--Icons Column--%>
                <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
                  <ItemTemplate>
                    <%# GetCompanyDataForCell((int)Eval("comp_CompanyID"),
                                        UIUtils.GetString(Eval("comp_PRBookTradestyle")),
                                        UIUtils.GetString(Eval("comp_PRLegalName")),
                                        UIUtils.GetBool(Eval("HasNote")),
                                        UIUtils.GetDateTime(Eval("comp_PRLastPublishedCSDate")),
                                        UIUtils.GetString(Eval("comp_PRListingStatus")),
                                        true,
                                        UIUtils.GetBool(Eval("HasNewClaimActivity")),
                                        UIUtils.GetBool(Eval("HasMeritoriousClaim")),
                                        UIUtils.GetBool(Eval("HasCertification")),
                                        UIUtils.GetBool(Eval("HasCertification_Organic")),
                                        UIUtils.GetBool(Eval("HasCertification_FoodSafety")),
                                        true,
                                        false,
                                        false,
                                        UIUtils.GetBool(Eval("OnWatchdogList")),
                                        UIUtils.GetString(Eval("WatchdogList"))
                                        )%>
                  </ItemTemplate>
                </asp:TemplateField>

                <%--Company Name column--%>
                <asp:TemplateField HeaderText="<%$ Resources:Global, CompanyName %>" HeaderStyle-CssClass="vertical-align-top" SortExpression="comp_PRBookTradestyle">
                  <ItemTemplate>
                    <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink"><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                    <asp:Literal ID="litLegalName" runat="server" Text='<%# PageBase.ParenWrap(UIUtils.GetString(Eval("comp_PRLegalName")))%>' />
                  </ItemTemplate>
                </asp:TemplateField>

                <%--Location Column--%>
                <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" DataField="CityStateCountryShort" SortExpression="CountryStAbbrCity" />

                <%--Type/Industry Column--%>
                <asp:TemplateField HeaderText="[replaced]" HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" SortExpression="comp_PRLocalSource, CompanyType">
                  <HeaderTemplate>
                    <asp:LinkButton ID="lbTypeIndustryColHeader" runat="server" Text="<%$ Resources:Global, TypeIndustry %>" CommandName="Sort" CommandArgument="comp_PRLocalSource, CompanyType" />
                    &nbsp;
                    <a id="popWhatIsIndustry" runat="server" class="clr_blc cursor_pointer" data-bs-html="true" style="color: #000;" data-bs-toggle="modal" data-bs-target="#pnlIndustry">
                      <span runat="server" data-bs-toggle="tooltip" class="msicon notranslate" data-bs-title="<%$ Resources:Global, WhatIsThis %>">help</span>
                    </a>
                  </HeaderTemplate>
                  <ItemTemplate>
                    <%# PageControlBaseCommon.GetIndustryTypeData(UIUtils.GetString(Eval("CompanyType")), UIUtils.GetString(Eval("IndustryType")), Eval("comp_PRLocalSource"), _oUser)%>
                  </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField HeaderText="<%$ Resources:Global, Phone2 %>" ItemStyle-CssClass="text-left text-nowrap" HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" DataField="Phone" SortExpression="Phone" />

                <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" HeaderText="<%$ Resources:Global, Rating %>">
                  <ItemTemplate>
                    <%# GetRatingCell(Eval("prra_RatingID"), Eval("prra_RatingLine"), Eval("IsHQRating"))%>
                  </ItemTemplate>
                </asp:TemplateField>
              </Columns>
            </asp:GridView>
          </div>
          <asp:Literal ID="litNoResultsMsg" runat="server" />
        </div>
      </div>

      <!-- Modal Industry type help-->
      <div id="pnlIndustry" class="modal fade" role="dialog">
        <div class="modal-dialog">
          <!-- Modal content-->
          <div class="modal-content">
            <div class="modal-header tw-flex tw-justify-between">
              <h5><%= Resources.Global.TypeIndustry %></h5>
              <button class="bbsButton bbsButton-secondary filled" data-bs-dismiss="modal" type="button">
                <span class="msicon notranslate">close</span>
              </button>
            </div>
            <div class="modal-body">
              <span class="sml_font">
                <%= Resources.Global.IndustryHelp %>
              </span>
            </div>
          </div>
        </div>
      </div>


      <%--      
      // See issue #54.  Hiding it from the user for now.
      // We should probably remove the code at some point but
      // restoring it would be a pain so let's make sure this
      // is want we want to do first.
      <div class="row">
            <div class="col-md-3 offset-md-1 nopadding">
              <div class="srch_btns">
                <asp:LinkButton ID="btnNewSearch" runat="server" CssClass="btn LargeButton gray_btn" OnClick="btnNewSearch_Click">
	                <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$ Resources:Global, NewSearch %>" />
                </asp:LinkButton>
              </div>
            </div>
          </div>
      --%>
    </div>

    <div class="tw-col-span-12 md:tw-col-span-2 tw-flex  tw-flex-col tw-gap-3">
      <!-- KYC CARD -->
      <asp:Panel ID="pnlKYC" runat="server" Visible="true" EnableViewState="false">
        <div class="bbs-card-bordered">
          <div class="bbs-card-header">
            <h5>
              <asp:Literal ID="litKYCHeader" runat="server" /></h5>
          </div>
          <div class="bbs-card-body">
            <p>
              <asp:Literal ID="hlKYC2" runat="server" />
            </p>
            <asp:HyperLink ID="hlKYC3" runat="server" Target="_blank"
              CssClass="bbsButton bbsButton-secondary small filled full-width tw-mt-2">
              <span>KYC</span>
              <span class="msicon notranslate">arrow_outward</span>
            </asp:HyperLink>
          </div>
        </div>

      </asp:Panel>

      <!-- Advertisements CARD -->
      <bbos:Advertisements ID="Advertisement" Title="Publicity" PageName="CompanySearchResults" CampaignType="IA,IA_180x90,IA_180x570" runat="server" />
    </div>
  </div>

  <div id="pnlRatingDef" style="display: none; width: 450px; min-height: 300px; height: auto; position: absolute; z-index: 100;" class="Popup">
    <div class="popup_header">
      <%--<span class="annotation" onclick="document.getElementById('pnlRatingDef').style.display='none';">Close</span>--%>
      <%--<img src="<% =UIUtils.GetImageURL("close.gif") %>" alt="Close" align="middle" onclick="document.getElementById('pnlRatingDef').style.display='none';" />--%>
      <button type="button" class="close" data-bs-dismiss="modal" onclick="document.getElementById('pnlRatingDef').style.display='none';">&times;</button>
    </div>
    <span id="ltRatingDef"></span>
  </div>
  <span id="litNonMemberRatingDef" style="display: none; visibility: hidden;">
    <%=Resources.Global.BBRatingsAvail %>
    <%--Blue Book Ratings are only available to licensed Blue Book Members.  Blue Book Ratings reflect the pay practices, attitudes, financial conditions and services of companies buying, selling & transporting fresh produce. --%>
    <a href="MembershipSelect.aspx">
      <%= Resources.Global.SignUpForMembershipToday1 %>
    </a>
    <%= Resources.Global.SignUpForMembershipToday2 %>
  </span>

  <a href="#" style="display: none; visibility: hidden;" onclick="return false" id="dummyLink" runat="server">dummy</a>
  <cc1:ModalPopupExtender ID="ModalPopupExtender1" runat="server"
    TargetControlID="dummyLink"
    PopupControlID="divZeroResults"
    DropShadow="true"
    BehaviorID="mpeZeroResults"
    OkControlID="btnSubmitFeedback"
    OnOkScript="submitFeedback();"
    CancelControlID="btnClose"
    BackgroundCssClass="modalBackground" />

  <div id="divZeroResults" class="Popup" style="width: 500px; display: none;">
    <div style="font-weight: bold; text-align: center;"><%=Resources.Global.WeWantToHearFromYou %></div>
    <p><% =Resources.Global.ZeroResultsFeedbackMsg%></p>

    <div class="text-center">
      <span class="annotation">
        <input type="checkbox" class="smallcheck" onclick="toggleDisplayZeroResults(this);" id="cbDontDisplayZeroResultsFeedback" /><label for="cbDontDisplayZeroResultsFeedback"><% =Resources.Global.DontDisplayThisMessageAgain%></label>
      </span>
      <br />
      <a href="#" id="btnSubmitFeedback" class="gray_btn"><% =Resources.Global.SubmitFeedback %></a>
      <a href="#" id="btnClose" class="gray_btn"><% =Resources.Global.Close %></a>
    </div>
  </div>
  <br />
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">
  <!-- Start Debugging Data -->
  <asp:Panel ID="pnlDebug" runat="server" Visible="false" CssClass="content-container">
    <table class="table table-striped table-hover">
      <tr>
        <td class="text-left">
          <i>SQL Returned:</i><br />
          <asp:Label ID="lblParameters" runat="server"></asp:Label>
          <asp:Label ID="lblSQL" runat="server"></asp:Label>
        </td>
      </tr>
    </table>
  </asp:Panel>
  <!-- End Debugging Data -->

  <script type="text/javascript">
    function setSelectedCount() {
      var c = getSelectedCountInternal("cbCompanyID");
      $('#<% =hidSelectedCount.ClientID %>').attr('value', c);

      setSelectedCountInternal("cbCompanyID", "lblSelectedCount", " <% =Resources.Global.Selected %>.");
    }

    setSelectedCount();

    function printList() {
      if ($("input[type='checkbox'][name='cbCompanyID']:checked").length == 0) {
        displayErrorMessage("<%=Resources.Global.PleaseSelectACompany%>");
        return false;
      }

      var oldBody = document.body.innerHTML;

      HideAnchorTags();
      HideUncheckedRows();
      printContent('SearchResults_PrintDiv');

      document.body.innerHTML = oldBody;
      location = location;
      return false;
    }
  </script>

  <script type="text/javascript" src="en-us/javascript/ideal-image-slider.js"></script>
  <script type="text/javascript" src="en-us/javascript/iis-bullet-nav.min.js"></script>
  <script type="text/javascript">
    var slider = new IdealImageSlider.Slider({
      selector: '#slider',
      effect: 'fade',
      interval: 4000
    });
    slider.addBulletNav();
    slider.start();
    $("#slider").removeClass("hidden");
  </script>

  <script type="text/javascript">
    $(".iis-slide").each(function () {
      var href = $(this).data('href');
      $(this).attr({
        href: href,
        target: '_blank'
      });
    });
    $(".iis-slide-blank").each(function () {
      var href = $(this).data('href');
      $(this).attr({
        href: href,
        target: '_blank'
      });
    });

  </script>
</asp:Content>
