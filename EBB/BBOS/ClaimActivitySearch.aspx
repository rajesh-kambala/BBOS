<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" EnableEventValidation="false" CodeBehind="ClaimActivitySearch.aspx.cs" Inherits="PRCo.BBOS.UI.Web.ClaimActivitySearch" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
  <script type="text/javascript">
    function ToggleCalendar() {
      // not rendered on the page if viewing results
      if (ddlDateRange == null) {
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

    function CompanyNameSelected(source, eventArgs) {
      if (eventArgs.get_value() != null) {

        if (hPageView.value == "1") {
          txtCompany.value = eventArgs.get_text();
          hCompanyID.value = "";
        } else {
          txtCompany.value = "";
          hCompanyID.value = eventArgs.get_value();
                    <%= GetSearchPostBack() %>;
        }
      }
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
    }
  </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="contentMain" runat="server">
  <asp:HiddenField ID="hPageView" runat="server" Value="1" />
  <asp:HiddenField ID="hCompanyID" runat="server" />

  <asp:Label ID="hidSearchID" runat="server" Visible="false" />

  <asp:Panel ID="pnlSearch" runat="server">
    <div class="tw-p-4">
      <asp:Panel ID="pnlCriteria" runat="server" CssClass="tw-flex tw-flex-col ">
        <%--Buttons--%>
        <div class="tw-flex tw-flex-wrap tw-gap-2 tw-justify-end tw-bg-bg-secondary tw-border-border tw-sticky p-3 border-bottom" style="top: 44px;z-index: 1;">
          <div>
          <asp:LinkButton ID="hlExpanded" runat="server" CssClass="bbsButton bbsButton-primary" OnClick="hlExpanded_Click" Visible="false">
                <span class="msicon notranslate" runat="server">zoom_in</span>
                <asp:Literal runat="server" Text="<%$Resources:Global, ViewExpanded %>" />
          </asp:LinkButton>
          <asp:LinkButton ID="hlBasic" runat="server" CssClass="bbsButton bbsButton-primary" OnClick="hlBasic_Click" Visible="false">
                <span class="msicon notranslate" runat="server">zoom_out</span>
                <asp:Literal runat="server" Text="<%$Resources:Global, ViewBasic %>" />
          </asp:LinkButton>
            </div>
          <div class="tw-flex tw-gap-3">
          <asp:LinkButton ID="btnClearCriteria" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClientClick="DisableValidation();" OnClick="btnClearCriteria_Click">
                 <span class="msicon notranslate" runat="server">clear</span>
                 <asp:Literal runat="server" Text="<%$Resources:Global, ClearCriteria %>" />
          </asp:LinkButton>
          <asp:LinkButton ID="btnSearch" runat="server" CssClass="bbsButton bbsButton-primary" OnClick="btnSearchOnClick">
                 <span class="msicon notranslate" runat="server">search</span>
                 <asp:Literal runat="server" Text="<%$Resources:Global, btnSearch %>" />
          </asp:LinkButton>
            </div>
        </div>

        <asp:Panel ID="pnlViewExpandedButton" runat="server" Visible="false">
          <div class="row nomargin_lr">
            <span class="annotation"><%=Resources.Global.SearchByClaimTypeDateRange %></span>
          </div>
        </asp:Panel>

        <asp:Panel ID="pnlViewBasicButton" runat="server" Visible="false" >
          <div class="row nomargin_lr">
            <span class="annotation"><%=Resources.Global.ViewLessInfoViewBasic %></span>
          </div>
        </asp:Panel>

        <div class="bbs-card-bordered ">
          <div class="bbs-card-header">
            <%=Resources.Global.ClaimsActivityTableCATSearchCriteria %>
          </div>
          <div class="bbs-card-body ">
            <div class="form-group">
              <div class="row" id="trBBNumber" runat="server">
                <asp:Label CssClass="clr_blu col-md-3" for="<%= txtBBNum.ClientID%>" runat="server"><%= Resources.Global.BBNumber %>:</asp:Label>
                <div class="col-md-6 ">
                  <div class="input-group tw-flex">
                    <asp:TextBox ID="txtBBID" runat="server" CssClass="form-control numbersOnly tw-flex-grow" MaxLength="8" AutoPostBack="True" />
                    <cc1:FilteredTextBoxExtender ID="ftbeBBID" runat="server" TargetControlID="txtBBID" FilterType="Numbers" />
                    <a id="popBBNumber" runat="server" class="input-group-text" data-bs-trigger="hover" data-bs-html="true" data-bs-toggle="popover" data-bs-placement="bottom">
                      <span class="msicon notranslate">help</span>
                    </a>
                  </div>
                </div>
              </div>

              <div class="row label_top">
                <asp:Label CssClass="clr_blu col-md-3" for="<%= txtCompany.ClientID%>" runat="server"><%= Resources.Global.CompanyName %>:</asp:Label>
                <div class="col-md-6">
                  <asp:TextBox ID="txtCompany" runat="server" CssClass="form-control" Columns="50" MaxLength="104" />
                </div>

                <cc1:AutoCompleteExtender ID="aceCompanyName" runat="server"
                  TargetControlID="txtCompany"
                  ServiceMethod="GetQuickFindCompletionList"
                  ServicePath="AJAXHelper.asmx"
                  CompletionInterval="100"
                  MinimumPrefixLength="2"
                  CompletionSetCount="30"
                  CompletionListCssClass="AutoCompleteFlyout"
                  CompletionListItemCssClass="AutoCompleteFlyoutItem"
                  CompletionListHighlightedItemCssClass="AutoCompleteFlyoutHilightedItem"
                  CompletionListElementID="pnlAutoComplete"
                  OnClientItemSelected="CompanyNameSelected"
                  OnClientPopulated="acePopulated"
                  EnableCaching="True"
                  UseContextKey="True"
                  FirstRowSelected="true">
                </cc1:AutoCompleteExtender>

                <div id="pnlAutoComplete" style="z-index: 5000;"></div>
              </div>

              <div class="row label_top" id="trClaimType" runat="server">
                <asp:Label CssClass="clr_blu col-md-3" for="<%= ddlClaimType.ClientID%>" runat="server"><%= Resources.Global.ClaimType %>:</asp:Label>
                <div class="col-md-6">
                  <asp:DropDownList CssClass="form-control" ID="ddlClaimType" runat="server">
                    <asp:ListItem Value="" Text="<%$Resources:Global, SelectAny %>" />
                    <asp:ListItem Value="BBS Claim" Text="<%$Resources:Global, BBSClaim %>" />
                    <asp:ListItem Value="Lawsuit" Text="<%$Resources:Global, Lawsuit %>" />
                    <asp:ListItem Value="PACA Claim" Text="<%$Resources:Global, PACAClaim %>" />
                  </asp:DropDownList>
                </div>
              </div>

              <div class="row label_top" id="trDateRange1" runat="server">
                <asp:Label CssClass="clr_blu col-md-3" for="<%= ddlDateRange.ClientID%>" runat="server"><%= Resources.Global.DateRange %>:</asp:Label>
                <div class="col-md-6">
                  <asp:DropDownList CssClass="form-control" ID="ddlDateRange" runat="server" />
                </div>
              </div>

              <div class="row label_top" id="trDateRange2" runat="server">
                <div class="col-md-6 offset-md-3">
                  <div class="input-group">
                    <asp:TextBox ID="txtDateFrom" runat="server" CssClass="form-control" Columns="14" MaxLength="10" tsiDate="true" tsiDisplayName="<%$ Resources:Global, FromDate %>" />
                    <span class="input-group-addon">-</span>
                    <asp:TextBox ID="txtDateTo" runat="server" CssClass="form-control" Columns="14" MaxLength="10" tsiDate="true" tsiDisplayName="<%$ Resources:Global, ToDate %>" />
                    <cc1:CalendarExtender runat="server" ID="ceDateFrom" TargetControlID="txtDateFrom" />
                    <cc1:CalendarExtender runat="server" ID="ceDateTo" TargetControlID="txtDateTo" />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <asp:Panel ID="pnlWatchdogList" runat="server">
          <div class="bbs-card-bordered ">
            <div class="bbs-card-header">
              <h5>
                <asp:Literal ID="litWatchdogListText" Text="<%$ Resources:Global, SelectWatchdogListsText %>" runat="server" /></h5>
            </div>
            <div class="bbs-card-body no-padding">
              <asp:GridView ID="gvUserList"
                AllowSorting="true"
                runat="server"
                AutoGenerateColumns="false"
                CssClass=" table table-hover"
                GridLines="None"
                OnSorting="UserListGridView_Sorting"
                OnRowDataBound="GridView_RowDataBound">

                <Columns>
                  <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center vertical-align-top">
                    <HeaderTemplate>
                      <% =Resources.Global.Select%><br />
                      <% =GetCheckAllCheckbox("cbUserListID")%>
                    </HeaderTemplate>
                    <ItemTemplate>
                      <input type="checkbox" name="cbUserListID" value="<%# Eval("prwucl_WebUserListID") %>"
                        <%# GetChecked((int)Eval("prwucl_WebUserListID")) %> onclick="refreshCriteria();" />
                    </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderText="<%$ Resources:Global, WatchdogListName %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-left  vertical-align-top" SortExpression="prwucl_Name">
                    <ItemTemplate>
                      <a href="<%# PageConstants.Format(PageConstants.USER_LIST, Eval("prwucl_WebUserListID")) %>" class="explicitlink">
                        <%# PageControlBaseCommon.GetCategoryIcon(Eval("prwucl_CategoryIcon"), Eval("prwucl_Name"))%>
                        <%# Eval("prwucl_Name")%>
                      </a>
                    </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center text-nowrap vertical-align-top" HeaderText="<%$ Resources:Global, Private %>" SortExpression="prwucl_IsPrivate">
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
        </asp:Panel>

      </asp:Panel>
    </div>
  </asp:Panel>
  <br />
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptSection" runat="server">
  <script type="text/javascript">
        //btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');
    </script>
</asp:Content>
