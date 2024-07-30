<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyUpdateSearch.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyUpdateSearch" MaintainScrollPositionOnPostback="true" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
      function ToggleCalendar() {
        // not rendered on the page if viewing results
        if (window.ddlDateRange == null) {
          return;
        }

        if (ddlDateRange.options[ddlDateRange.selectedIndex].value == "") {
          txtDateFrom.disabled = false;
          txtDateTo.disabled = false;
          //lblThrough.disabled = false;
        } else {
          txtDateFrom.disabled = true;
          txtDateTo.disabled = true;
          //lblThrough.disabled = true;
        }
      }

      function postStdValidation() {
        szMsg = IsValidDateRange(txtDateFrom, txtDateTo);
        if (szMsg != "") {
          displayErrorMessage(szMsg);
          return false;
        }
        return true;
      }

      (function () {
        // Execute ToggleCalendar on load.
        if (window.addEventListener) {
          window.addEventListener("load", ToggleCalendar, false); // preferably standards compliant (firefox, etc)
        } else if (window.attachEvent) {
          window.attachEvent("onload", ToggleCalendar); // otherwise it's ie
        }
      })();
    </script>
    <style>
      .main-content-old {
        width: 100%;
        padding: 16px;
      }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server" >
    <asp:Label ID="hidSearchID" runat="server" Visible="false" />

  <%--Search Form--%>
  <asp:Panel ID="pnlSearch" DefaultButton="btnSearch1" runat="server" CssClass="tw-flex tw-flex-col mb-3">
    <%--Buttons--%>
    <div class="tw-flex tw-flex-wrap tw-gap-2 tw-justify-end tw-bg-bg-secondary tw-border-border tw-sticky p-3 border-bottom" style="top: 44px;z-index: 1;">
      <asp:LinkButton ID="btnRefine1" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnRefineOnClick">
          <span class="msicon notranslate" runat="server">edit</span>
          <span class="text-lable"><asp:Literal runat="server" Text="<%$Resources:Global, EditSearchCriteria %>" /></span>
      </asp:LinkButton>

      <asp:LinkButton ID="btnNewSearch1" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnNewSearch_Click" OnClientClick="return confirmOverrwrite('NewSearch')">
          <span class="msicon notranslate" runat="server">feature_search</span>
          <span class="text-lable"><asp:Literal runat="server" Text="<%$Resources:Global, NewSearch %>" /></span>
      </asp:LinkButton>

      <asp:LinkButton ID="btnCompanyUpdateReport1" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnCompanyUpdateReportOnClick">
          <span class="msicon notranslate" runat="server">download</span>
          <span class="text-lable"><asp:Literal runat="server" Text="<%$Resources:Global, btnCompanyUpdateReport %>" /></span>
      </asp:LinkButton>

      <asp:LinkButton ID="btnCompanyUpdateExport1" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnCompanyUpdateExportOnClick">
          <span class="msicon notranslate" runat="server">export_notes</span>
          <span class="text-lable"><asp:Literal runat="server" Text="<%$Resources:Global, btnExportData %>" /></span>
      </asp:LinkButton>

      <asp:LinkButton ID="btnAddToWatchdogList1" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnAddToWatchdogListOnClick">
          <span class="msicon notranslate" runat="server">playlist_add</span>
          <span class="text-lable"><asp:Literal runat="server" Text="<%$Resources:Global, btnAddToWatchdogList %>" /></span>
      </asp:LinkButton>
      <asp:LinkButton ID="btnClearCriteria1" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnClearCriteria_Click">
          <span class="msicon notranslate" runat="server">clear_all</span>
          <span class="text-lable"><asp:Literal runat="server" Text="<%$Resources:Global, ClearAll %>" /></span>
      </asp:LinkButton>
      <asp:LinkButton ID="btnSaveCriteria1" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnSaveCritiera_Click">
          <span class="msicon notranslate" runat="server">saved_search</span>
          <span class="text-lable"><asp:Literal runat="server" Text="<%$Resources:Global, SaveSearch %>" /></span>
      </asp:LinkButton>

      <asp:LinkButton ID="btnSearch1" runat="server" CssClass="bbsButton bbsButton-primary" OnClick="btnSearchOnClick">
          <span class="msicon notranslate" runat="server">search</span>
          <span class="text-lable"><asp:Literal runat="server" Text="<%$Resources:Global, btnSearch %>" /></span>
      </asp:LinkButton>
    </div>
    <asp:Panel ID="pnlCriteria" runat="server" CssClass="tw-flex tw-gap-4 tw-flex-col">
        <div class="bbs-card-bordered ">
          <div class="bbs-card-header">
            <%=Resources.Global.CompanySearchCriteria %>
          </div>
          <div class="bbs-card-body" id="pnlCriteriaDetails">
            <div class="form-group">
              <div class="row label_top" id="trDateRange1" runat="server">
                <asp:Label CssClass="clr_blu col-md-2" for="<%= ddlDateRange.ClientID%>" runat="server"><%= Resources.Global.DateRange %>:</asp:Label>
                <div class="col-md-4">
                  <asp:DropDownList CssClass="form-control" ID="ddlDateRange" runat="server" />
                </div>
              </div>

              <div class="row label_top" id="trDateRange2" runat="server">
                <div class="col-md-8 offset-md-2">
                  <div class="input-group">
                    <asp:TextBox ID="txtDateFrom" runat="server" CssClass="form-control" Columns="12" MaxLength="10"
                      tsiDate="true" tsiDisplayName="<%$ Resources:Global, FromDate %>" />
                    <cc1:CalendarExtender runat="server" ID="ceDateFrom" TargetControlID="txtDateFrom" />
                    <span class="input-group-addon">-</span>
                    <asp:TextBox ID="txtDateTo" runat="server" CssClass="form-control" Columns="12" MaxLength="10"
                      tsiDate="true" tsiDisplayName="<%$ Resources:Global, ToDate %>" />

                    <cc1:CalendarExtender runat="server" ID="ceDateTo" TargetControlID="txtDateTo" />
                  </div>
                </div>
              </div>

              <div class="row label_top" id="trKeyChanges" runat="server">

                <div class="col-md-8 form-inline tw-flex tw-gap-2 tw-it">
                  <asp:CheckBox ID="cbKeyChangesOnly" runat="server" />
                  <asp:Label CssClass="clr_blu fw-normal" AssociatedControlID="cbKeyChangesOnly"  runat="server"><%= Resources.Global.KeyChangesOnly %></asp:Label>
                  <a id="popKeyChangesOnly" runat="server" class="bbsButton bbsButton-tertiary tw-text-text-secondary p-0" data-bs-trigger="hover" data-bs-html="true"  data-bs-toggle="popover" data-bs-placement="bottom">
                    <span class="msicon notranslate">help</span>
                  </a>
                </div>
              </div>

              <div class="row label_top" runat="server">
                <div class="col-md-8 form-inline">
                  <asp:CheckBox ID="cbIncludeNewListing" runat="server" />
                  <asp:Label CssClass="clr_blu fw-normal" AssociatedControlID="cbIncludeNewListing" runat="server"><%= Resources.Global.IncludeNewListings %></asp:Label>
                </div>
              </div>
            </div>
          </div>
        </div>
        <asp:Panel ID="pnlWatchdogList" runat="server">
          <div class="bbs-card-bordered ">
            <div class="bbs-card-header">
              <asp:Literal ID="litWatchdogListText" Text="<%$ Resources:Global, SelectWatchdogListsText %>" runat="server" />
            </div>
            <div class="bbs-card-body no-padding">

              <div class="table-responsive">
                <asp:GridView ID="gvUserList"
                  AllowSorting="true"
                  runat="server"
                  AutoGenerateColumns="false"
                  CssClass="table table-hover"
                  GridLines="None"
                  OnSorting="UserListGridView_Sorting"
                  OnRowDataBound="gvUserList_RowDataBound">

                  <Columns>
                    <asp:TemplateField ItemStyle-CssClass="text-center vertical-align-top" HeaderStyle-CssClass="text-center vertical-align-top">
                      <HeaderTemplate>
                        <!--% =Resources.Global.Select%-->
                        <!--br /-->
                        <% =GetCheckAllCheckbox("cbUserListID")%>
                      </HeaderTemplate>
                      <ItemTemplate>
                        <input type="checkbox" name="cbUserListID" value="<%# Eval("prwucl_WebUserListID") %>"
                          <%# GetChecked((int)Eval("prwucl_WebUserListID")) %> onclick="refreshCriteria();" />
                      </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="<%$ Resources:Global, WatchdogListName %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left vertical-align-top" SortExpression="prwucl_Name">
                      <ItemTemplate>
                        <a href="<%# PageConstants.Format(PageConstants.USER_LIST, Eval("prwucl_WebUserListID")) %>" class="explicitlink">
                          <%# PageControlBaseCommon.GetCategoryIcon(Eval("prwucl_CategoryIcon"), Eval("prwucl_Name"))%>
                          <%# Eval("prwucl_Name")%>
                        </a>
                      </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-top" HeaderText="<%$ Resources:Global, Private %>" SortExpression="prwucl_IsPrivate">
                      <ItemTemplate>
                        <%# UIUtils.GetStringFromBool(Eval("prwucl_IsPrivate"))%>
                      </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left vertical-align-top" HeaderText="<%$ Resources:Global, UpdatedDate_NoBR %>" SortExpression="UpdatedDate">
                      <ItemTemplate>
                        <%# GetStringFromDate(Eval("UpdatedDate"))%>
                      </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField HeaderText="<%$ Resources:Global, CompanyCount %>" HeaderStyle-CssClass="text-left vertical-align-top" ItemStyle-CssClass="text-left vertical-align-top" DataField="CompanyCount" SortExpression="CompanyCount" />
                  </Columns>
                </asp:GridView>
              </div>
            </div>
          </div>
        </asp:Panel>
      </asp:Panel>
  </asp:Panel>

    <%--Results--%>
    <asp:Panel ID="pnlResults" runat="server">


      <div class="bbs-card-bordered ">
        <div class="bbs-card-header tw-flex tw-justify-between">
          <div class="">
            <asp:Label ID="lblRatingNumeralDefinitions" CssClass="bbsButton bbsButton-secondary filled small" Text="<%$ Resources:Global, AllRatingDefinitions %>" runat="server" />
            <asp:Panel ID="pnlRatingNumeralDefinition" Style="display: none; height: 500px; width: 500px; font-weight: normal;" CssClass="Popup" runat="server" />
            <cc1:PopupControlExtender ID="pceRatingNumeralDefinition" runat="server" TargetControlID="lblRatingNumeralDefinitions" PopupControlID="pnlRatingNumeralDefinition" OffsetX="-100" Position="bottom" />
            <cc1:DynamicPopulateExtender ID="dpeRatingNumeralDefinition" runat="server" TargetControlID="pnlRatingNumeralDefinition" PopulateTriggerControlID="lblRatingNumeralDefinitions" ServiceMethod="GetRatingNumeralsDefinitions" ServicePath="AJAXHelper.asmx" CacheDynamicResults="true" />
          </div>
          <div>
            <%--Record Count--%>
            <div class="tw-flex tw-gap-3">
              <asp:Label ID="lblRecordCount" CssClass="tag" runat="server" />
              <span class="tag" id="lblSelectedCount"></span>
            </div>
            <asp:HiddenField ID="hidSelectedCount" runat="server" Value="0" />
            <asp:HiddenField ID="hidExportsMax" runat="server" Value="0" />
            <asp:HiddenField ID="hidExportsUsed" runat="server" Value="0" />
            <asp:HiddenField ID="hidExportsPeriod" runat="server" Value="M" />
            <asp:HyperLink ID="hlAd" runat="server" Target="_blank" Visible="false" />
          </div>
        </div>
        <div class="bbs-card-body no-padding">
          <div class="table-responsive">
            <asp:GridView ID="gvSearchResults"
              AllowSorting="true"
              runat="server"
              AutoGenerateColumns="false"
              CssClass=" table table-hover"
              GridLines="None"
              OnSorting="GridView_Sorting"
              OnRowDataBound="gvSearchResults_RowDataBound">

              <Columns>
                <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-top">
                  <HeaderTemplate>
                    <!--% =Resources.Global.Select%-->
                    <!--br /-->
                    <% =PageBase.GetCheckAllCheckbox("cbCreditSheetID", "setSelectedCount();")%>
                  </HeaderTemplate>
                  <ItemTemplate>
                    <input type="checkbox" name="cbCreditSheetID" value="<%# Eval("prcs_CreditSheetId") %>" onclick="setSelectedCount();" />
                  </ItemTemplate>
                </asp:TemplateField>


                <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="text-nowrap vertical-align-top"
                  DataField="comp_CompanyID" SortExpression="comp_CompanyID" />

                <%--Icons Column--%>
                <asp:TemplateField HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
                  <HeaderTemplate>
                    <span class="msicon notranslate">notifications_active</span>
                    </HeaderTemplate>
                  <ItemTemplate>
                    <%# GetCompanyDataForCell((int)Eval("comp_CompanyID"), 
                                (string)Eval("comp_PRBookTradestyle"), 
                                (string)Eval("comp_PRLegalName"), 
                                UIUtils.GetBool(Eval("HasNote")), 
                                UIUtils.GetDateTime(Eval("comp_PRLastPublishedCSDate")), 
                                (string)Eval("comp_PRListingStatus"), 
                                true, 
                                UIUtils.GetBool(Eval("HasNewClaimActivity")), 
                                UIUtils.GetBool(Eval("HasMeritoriousClaim")), 
                                UIUtils.GetBool(Eval("HasCertification")), 
                                UIUtils.GetBool(Eval("HasCertification_Organic")), 
                                UIUtils.GetBool(Eval("HasCertification_FoodSafety")), 
                                true, 
                                false)%>
                    <br />
                  </ItemTemplate>
                </asp:TemplateField>

                <%--Company Name column--%>
                <asp:TemplateField HeaderText="<%$ Resources:Global, CompanyName %>" HeaderStyle-CssClass="vertical-align-top" SortExpression="comp_PRBookTradestyle">
                  <ItemTemplate>
                    <asp:HyperLink ID="hlCompanyDetails" runat="server" CssClass="explicitlink" NavigateUrl='<%# Eval("comp_CompanyID", "~/CompanyDetailsSummary.aspx?CompanyID={0}")%>'><%# Eval("comp_PRBookTradestyle") %></asp:HyperLink>
                    <asp:Literal ID="litLegalName" runat="server" Text='<%# PageBase.ParenWrap(Eval("comp_PRLegalName"), true)%>' />
                  </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="vertical-align-top"
                  DataField="CityStateCountryShort" SortExpression="CountryStAbbrCity" />

                <asp:TemplateField HeaderText="<%$ Resources:Global, DateOfUpdate %>" HeaderStyle-CssClass="vertical-align-top" SortExpression="prcs_PublishableDate"
                  ItemStyle-CssClass="text-left vertical-align-top">
                  <ItemTemplate>
                    <%# PageBase.GetStringFromDate(Eval("prcs_PublishableDate"))%>
                  </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="vertical-align-top" HeaderText="<%$ Resources:Global, Key %>" SortExpression="prcs_KeyFlag">
                  <ItemTemplate>
                    <%# UIUtils.GetStringFromBool(Eval("prcs_KeyFlag"))%>
                  </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="<%$ Resources:Global, UpdateItem %>" HeaderStyle-CssClass="text-left vertical-align-top" ItemStyle-CssClass="text-left">
                  <ItemTemplate>
                    <%# Eval("ItemText")%>
                  </ItemTemplate>
                </asp:TemplateField>
              </Columns>
            </asp:GridView>
          </div>
        </div>
      </div>
    </asp:Panel>
    
    <br />
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript" id="bbsiGetAdsWidget" src="<asp:Literal ID="litAdWidget" runat="server" />"></script>
    <script type="text/javascript">
      function setSelectedCount() {
        var c = getSelectedCountInternal("cbCreditSheetID");
        $('#<% =hidSelectedCount.ClientID %>').attr('value', c);

        if (document.getElementById("lblSelectedCount") != null)
          setSelectedCountInternal("cbCreditSheetID", "lblSelectedCount");
      }

      setSelectedCount();
      btnSubmitOnEnter = document.getElementById('<% =btnSearch1.ClientID %>');
    </script>
</asp:Content>
