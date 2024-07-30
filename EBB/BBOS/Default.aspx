<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PRCo.BBOS.UI.Web.Default"  %>

<%@ Register Src="~/UserControls/SystemMessage.ascx" TagName="SystemMessage" TagPrefix="BBOS" %>
<%@ Register Src="~/UserControls/News.ascx" TagName="News" TagPrefix="BBOS" %>
<%@ Register Src="~/UserControls/MyAccount.ascx" TagName="MyAccount" TagPrefix="BBOS" %>
<%@ Register Src="~/UserControls/MenuSearch.ascx" TagName="MenuSearch" TagPrefix="BBOS" %>

<%@ Register Src="~/Widgets/CompaniesRecentlyViewed.ascx" TagName="CompaniesRecentlyViewed" TagPrefix="BBOSWidget" %>
<%@ Register Src="~/Widgets/ListingsRecentlyPublished.ascx" TagName="ListingsRecentlyPublished" TagPrefix="BBOSWidget" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ID="contentHead" ContentPlaceHolderID="contentHead" runat="server">
  <link rel="stylesheet" href="Content/ideal-image-slider.css" />
  <link rel="stylesheet" href="Content/ideal-image-slider_default.css" />

  <style >
    #slider {
      max-width: 1150px;
      margin: 15px auto;
    }
  </style>
</asp:Content>

<asp:Content ID="contentMain" ContentPlaceHolderID="contentMain" runat="server">
  <asp:Button ID="btnBBOSPopup" runat="server" style="display:none;" />

  <div id="slider" class="hidden">
    <asp:Literal ID="microslider" runat="server" />
  </div>

  <div class="px-4">
    <div
      class="tw-grid tw-grid-cols-1 tw-gap-4 md:tw-grid-cols-2 lg:tw-grid-cols-3 tw-pt-2"
    >
      <div><BBOS:SystemMessage ID="ucSystemMessage" runat="server" /></div>
      <div><BBOS:News ID="ucNews" runat="server" /></div>
      <div><BBOS:MyAccount ID="ucMyAccount" runat="server" /></div>
    </div>
  </div>

  <!--Panels Start Here-->
  <!-- TODO: Temporarily hiding the quick links panels: Defect 7331. Remove permanently later -->
  <div class=" py-3 px-4 tw-hidden">
    <div
      class="tw-grid tw-grid-cols-1 tw-gap-4 md:tw-grid-cols-2 lg:tw-grid-cols-3"
    >
      <div>
        <div class="bbs-list-panel">
          <div class="bbs-list-panel-heading">
            <h3 class=""><% =Resources.Global.QuickSearch%></h3>
          </div>
          <div class="bbs-list-group">
            <div id="liCompanySearch" runat="server">
              <asp:LinkButton ID="hlCompanySearch" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, NewCompanySearch %>" OnClick="btnCompanySearchOnClick" />
            </div>
            <div id="liClaimActivitySearch" runat="server">
              <asp:HyperLink ID="hlClaimActivitySearch" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, SearchClaimsActivityTableCAT %>" />
            </div>
            <div id="liPersonSearch" runat="server">
              <asp:HyperLink ID="hlPersonSearch" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, NewPersonSearch %>" />
            </div>
            <div id="liCompanyUpdateSearch" runat="server">
              <asp:HyperLink ID="hlCompanyUpdateSearch" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, NewCreditSheetSearch %>" />
            </div>
            <div id="liSavedSearches" runat="server">
              <asp:HyperLink ID="hlSavedSearches" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, BrowseSavedSearches %>" />
            </div>
            <div id="liRecentViews" runat="server">
              <asp:HyperLink ID="hlRecentViews" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, RecentViews %>" />
            </div>
            <div id="liLastCompanySearch" runat="server">
              <asp:HyperLink ID="hlLastCompanySearch" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, LastCompanySearch %>" />
            </div>
          </div>
        </div>
      </div>
      <div>
        <div class="bbs-list-panel">
          <div class="bbs-list-panel-heading">
            <h3 class=""><%=Resources.Global.Resources %></h3>
          </div>
          <div class="bbs-list-group">
            <div id="liSpecialServices" runat="server">
              <asp:HyperLink ID="hlSpecialServices" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, TradingAssistance %>" />
            </div>
            <div id="liWatchodgLists" runat="server">
              <asp:HyperLink ID="hlWatchdogLists" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, WatchdogListsAlerts %>" />
            </div>
            <div id="liNotes" runat="server">
              <asp:HyperLink ID="hlNotes" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, Notes %>" />
            </div>
            <div id="liCustomFields" runat="server">
              <asp:HyperLink ID="hlCustomFields" runat="server" CssClass="bbs-list-item" Text="<%$ Resources:Global, CustomData %>" />
            </div>
            <div id="liPurchases" runat="server">
              <asp:HyperLink ID="hlPurchases" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, Purchases %>" />
            </div>
            <div id="liAdditionalTools" runat="server">
              <asp:HyperLink ID="hlAdditionalTools" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, AdditionalTools %>" />
            </div>
            <div id="liTES" runat="server">
              <asp:HyperLink ID="hlTES" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, TradeExperienceSurvey%>" />
            </div>
          </div>
        </div>
      </div>
      <div>
        <div class="bbs-list-panel">
          <div class="bbs-list-panel-heading">
            <h3 class=""><%=Resources.Global.Education %></h3>
          </div>
          <div class="bbs-list-group">
            <div id="liLearningCenter" runat="server">
              <asp:HyperLink ID="hlLearningCenter" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, LearningCenter %>" />
            </div>
            <div id="liBlueprints" runat="server">
              <asp:HyperLink ID="hlBlueprints" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, ProduceBlueprintsMagazine %>" />
            </div>
            <div id="liKnowYourCommodity" runat="server">
              <asp:HyperLink ID="hlKnowYourCommodity" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, KnowYourCommodity %>" />
            </div>
            <div id="liBluebookReference" runat="server">
              <asp:HyperLink ID="hlBluebookReference" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, ReferenceGuide %>" />
            </div>
            <div id="liBluebookServices" runat="server">
              <asp:HyperLink ID="hlBluebookServices" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, BlueBookServices %>" />
            </div>
            <div id="liNewHireAcademy" runat="server">
              <asp:HyperLink ID="hlNewHireAcademy" runat="server" CssClass="bbs-list-item" Text="<%$Resources:Global, NewHireAcademy %>" />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="clearfix"></div>

  <!--User-Defined Panels Start Here-->
  <div class=" py-3 px-4">
    <div class="row">
      <asp:Repeater ID="repWidgets" runat="server" OnItemDataBound="repWidgets_ItemDataBound">
        <ItemTemplate>
          <div class="col-md-6 py-3">
            <asp:PlaceHolder ID="phWidget" runat="server" />
          </div>
        </ItemTemplate>
      </asp:Repeater>
    </div>
    <div class="row">
      <div class="col-6 py-3">
        <!--QA Start Here-->
        <asp:Panel ID="pnlQA" Visible="false" runat="server" CssClass="bbs-list-panel">
          <div class="bbs-list-panel-heading">
            <h3 class=""><% =Resources.Global.QualityAssurance%></h3>
          </div>
          <div class="bbs-list-group">
            <div>
              <asp:HyperLink ID="hlQA" Text="<%$Resources:Global, QAPage %>" runat="server" CssClass="bbs-list-item" />
            </div>
            <div>
              <asp:HyperLink ID="hlSystemInfo" Text="<%$Resources:Global, SystemInfo %>" runat="server" CssClass="bbs-list-item" Visible="false" />
            </div>
          </div>
        </asp:Panel>
      </div>
    </div>
  </div>

  <asp:Panel ID="pnlBBOSPopup" Style="display: none;" CssClass="Popup" Width="800px" Height="525px" runat="server">
    <asp:HiddenField ID="hdnPublicationArticleID" runat="server" />
    <asp:Literal ID="litBBOSPopup" runat="server" />

    <div style="text-align: center; position: absolute; bottom: 0; padding-top: 10px; padding-bottom: 5px; margin-right: 25px; width: 100%;">
      <asp:LinkButton ID="btnOK" runat="server" CssClass="btn gray_btn" OnClick="btnDismissBBOSPopupClick">
        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Dismiss %>" />
      </asp:LinkButton>

      <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnRemindBBOSPopupClick">
        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, RemindMeLater %>" />
      </asp:LinkButton>
    </div>
  </asp:Panel>

  <cc1:modalpopupextender
    id="mpeBBOSPopup"
    behaviorid="mpeBBOSPopup"
    targetcontrolid="btnBBOSPopup"
    popupcontrolid="pnlBBOSPopup"
    dropshadow="true"
    popupdraghandlecontrolid="hdnPublicationArticleID"
    backgroundcssclass="modalBackground"
    runat="server" />

  <asp:Panel ID="pnlNoteReminder" runat="server" CssClass="Popup" align="center" Style="display: none" ScrollBars="Auto" Width="90%" Height="90%">
    <h2>Note Reminders</h2>
    <div class="row nomargin_lr">
      <asp:GridView ID="gvNotes"
        Width="100%"
        runat="server"
        AutoGenerateColumns="false"
        CssClass="table table-striped table-hover"
        GridLines="none"
      >

        <Columns>
          <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-top">
            <HeaderTemplate>
              Select
              <br />
              <% =GetCheckAllCheckbox("cbNote") %>
            </HeaderTemplate>
            <ItemTemplate>
              <input type="checkbox" name="cbNote" value="<%# Eval("prwun_WebUserNoteID") %>" />
            </ItemTemplate>
          </asp:TemplateField>

          <asp:TemplateField HeaderStyle-CssClass="text-left text-nowrap  vertical-align-top" ItemStyle-CssClass="text-nowrap" HeaderText="<%$ Resources:Global, Subject %>" SortExpression="Subject">
            <ItemTemplate>
              <%# GetNoteSubject((int)Eval("prwun_AssociatedID"), (string)Eval("prwun_AssociatedType"), (string)Eval("Subject"), true, true)%>
            </ItemTemplate>
          </asp:TemplateField>

          <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center text-nowrap  vertical-align-top" HeaderText="<%$ Resources:Global, Private %>" SortExpression="prwun_IsPrivate">
            <ItemTemplate>
              <%# UIUtils.GetStringFromBool((bool)Eval("prwun_IsPrivate"))%>
            </ItemTemplate>
          </asp:TemplateField>

          <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left text-nowrap  vertical-align-top" HeaderText="<%$Resources:Global, DateTime%>" SortExpression="prwun_Date">
            <ItemTemplate>
              <%# ((IPRWebUserNote)Container.DataItem).GetFormattedDateTime("<br/>")%>
            </ItemTemplate>
          </asp:TemplateField>

          <asp:TemplateField HeaderStyle-CssClass="text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, Note %>">
            <ItemTemplate>
              <%# ((IPRWebUserNote)Container.DataItem).GetTruncatedText(300)%>&nbsp;&nbsp;<asp:LinkButton ID="viewMore" runat="server" Text="<%$Resources:Global, ViewMoreddd %>" CssClass="explicitlink" />

              <asp:Panel ID="Note" Width="600px" runat="server" Style="display: none; max-height: 600px;" CssClass="PopupListing">
                <div style="height: 400px; overflow: auto;">
                  <%# Eval("prwun_Note")%>
                </div>
                <div style="margin-top: 10px; text-align: center;">
                  <asp:LinkButton ID="Close" runat="server" CssClass="btn gray_btn">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Close %>" />
                  </asp:LinkButton>
                </div>
              </asp:Panel>

              <cc1:ModalPopupExtender ID="ModalPopupExtender1" runat="server"
                TargetControlID="viewMore"
                PopupControlID="Note"
                OkControlID="Close"
                BackgroundCssClass="modalBackground" />

            </ItemTemplate>
          </asp:TemplateField>
        </Columns>
      </asp:GridView>
    </div>

    <div class="row">
      <div class="col-md-12 text-center">
        <asp:LinkButton ID="btnDismssSelected" runat="server" CssClass="btn gray_btn" OnClick="dismissSelected" OnClientClick="return confirmSelect2('note', 'cbNote', 'dimiss')">
          <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, DismissSelected %>" />
        </asp:LinkButton>
        <asp:LinkButton ID="btnDismssAll" runat="server" CssClass="btn gray_btn" OnClick="dismissAll" OnClientClick="return confirm('Are you sure you want to dismiss all these note reminders?');">
          <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, DismissAll %>" />
        </asp:LinkButton>
        <asp:LinkButton runat="server" CssClass="btn gray_btn" OnClick="btnClose_Click">
          <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Snooze %>" />
        </asp:LinkButton>
      </div>
    </div>
  </asp:Panel>

  <span style="display: none;">
    <asp:Button ID="btnNoteReminder" runat="server" /></span>
  <cc1:ModalPopupExtender ID="mpeNoteReminder" runat="server"
    TargetControlID="btnNoteReminder"
    PopupControlID="pnlNoteReminder"
    BackgroundCssClass="modalBackground" />

  <div id="openInvoiceModal" class="modal fade">
    <div class="modal-dialog modal-lg">
      <div class="modal-content">
        <div class="modal-header">
            <h5 class="modal-title"><span style="font-size:x-large;"><b><asp:Literal ID="litInvoiceModalTitle" runat="server" /></b></span></h5>
            <button type='button' id="btnClose" class='close' data-bs-dismiss='modal'>&times;</button>
        </div>
        <div class="modal-body">
          <p><asp:Literal ID="litInvoiceModalMessage" runat="server" /></p><br />
          <p><asp:Literal ID="litInvoiceModalFooter" runat="server" /></p>
          <p id="pLogoff">
             <asp:LinkButton ID="btnLogoff2" runat="server" CssClass="btn gray_btn" OnClick="btnLogoff_Click" Width="100%">
                 <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Logoff %>" />
             </asp:LinkButton>
          </p>
        </div>
      </div>
    </div>
  </div>

  <asp:Panel ID="pnlCrossIndustryCheck" runat="server" Visible="false">
    <div class="row">
      <div class="col-12 text-center">
        <asp:Button ID="btnCrossIndustry" runat="server" CssClass="btn gray_btn" OnClick="btnCrossIndustry_Click" />
      </div>
    </div>
  </asp:Panel>
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">

    <script type="text/javascript" src="en-us/javascript/ideal-image-slider.js"></script>
  <script type="text/javascript" src="en-us/javascript/iis-bullet-nav.min.js"></script>

  <script type="text/javascript">
    var slider = new IdealImageSlider.Slider({
      selector: '#slider',
      effect: 'fade',
      interval: 5000
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

  <script type="text/javascript">
    $(".messages").removeClass("explicitlink");

      function invoiceMessageRender() {
          if (bSuspend) {
              $('#openInvoiceModal').attr('data-bs-backdrop', 'static');
              $('#btnClose').hide();
              $('#pLogoff').show();
          }
          else {
              $('#btnClose').show();
              $('#pLogoff').hide();
          }

          $('#openInvoiceModal').modal('show');
      }

    $(document).ready(function () {
      

      if (bDisplayInvoiceMessage)
        invoiceMessageRender();
    });

    //Defect 6895
    var _displayBBOSPopup = false;
    function displayBBOSPopup() {
      _displayBBOSPopup = true;
    }

    function pageLoad() {
      if (_displayBBOSPopup) {
        $find("mpeBBOSPopup").show();
      }
    }

  </script>
</asp:Content>

<asp:Content ID="contentLeftSidebar" ContentPlaceHolderID="contentLeftSidebar" runat="server">
</asp:Content>
