<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserList.aspx.cs" Inherits="PRCo.BBOS.UI.Web.UserList" MasterPageFile="~/BBOS.Master" MaintainScrollPositionOnPostback="true" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
  <script type="text/javascript">
</script>
  <style>
    .content-container div.row a.gray_btn {
      display: inline;
      width: auto;
      margin-right: 10px;
      margin-bottom: 20px;
    }

    .main-content-old {
      max-width: 100%;
      width: 100%;
    }
  </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
  <asp:HiddenField ID="hidUserListID" runat="server" />
  <asp:HiddenField ID="hidListType" runat="server" />
  <asp:HiddenField ID="hidWebUserID" runat="server" />
  <asp:HiddenField ID="hidSelectedCompanyIDs" runat="server" />

  <div class="tw-flex tw-flex-col tw-gap-3">

  <asp:LinkButton ID="btnBack" runat="server" CssClass="bbsButton bbsButton-secondary filled small" OnClick="btnBack_Click">
	<span class="msicon notranslate" aria-hidden="true" runat="server">arrow_back</span>
    <asp:Literal runat="server" Text="<%$Resources:Global, btnBack %>" />
  </asp:LinkButton>

  <div class="bbs-card-bordered tw-w-fit">
    <div class="bbs-card-header tw-flex tw-gap-8 justify-content-between">
      <asp:Literal runat="server" Text="<%$Resources:Global, WatchdogListName %>" />
      <div class="bbsButton-group-nowrap">
        <asp:LinkButton ID="btnManageAlertsSettings" runat="server" CssClass="bbsButton bbsButton-secondary filled small" OnClick="btnManageAlertsSettings_Click" Visible="false">
		    <span class="msicon notranslate" aria-hidden="true" runat="server">notifications</span>
          <asp:Literal runat="server" Text="<%$Resources:Global, btnManageAlertsSettings %>" />
        </asp:LinkButton>
        <asp:LinkButton ID="btnManageConnList" runat="server" CssClass="bbsButton bbsButton-secondary filled small" OnClick="btnManageConnList_Click" Visible="false">
		    <span class="msicon notranslate" aria-hidden="true" runat="server">hub</span>
          <asp:Literal runat="server" Text="<%$Resources:Global, btnManageConnectionList %>" />
        </asp:LinkButton>
        <asp:LinkButton ID="btnEdit" runat="server" CssClass="bbsButton bbsButton-secondary filled small" OnClick="btnEdit_Click">
		    <span class="msicon notranslate" aria-hidden="true" runat="server">edit</span>
          <asp:Literal runat="server" Text="<%$Resources:Global, Edit %>" />
        </asp:LinkButton>
      </div>
    </div>
    <div class="bbs-card-body no-padding">
      <ul class="list-group list-group-flush">
        <li class="list-group-item d-flex justify-content-between align-items-center">
          <asp:Label for="<%= lblListName.ClientID%>" runat="server" CssClass="bbos_blue" Text="<%$ Resources:Global,Name_Cap %>" />
          <span>
            <asp:Label ID="lblListName" runat="server" CssClass="blacktext" /></span>
        </li>

        <li class="list-group-item d-flex justify-content-between align-items-center">
          <asp:Label for="<%= lblListDescription.ClientID%>" runat="server" CssClass="bbos_blue" Text="<%$ Resources:Global, Description %>" />
          <span>
            <asp:Label ID="lblListDescription" runat="server" CssClass="blacktext" /></span>
        </li>

        <li class="list-group-item d-flex justify-content-between align-items-center">
          <asp:Label for="<%= Icon.ClientID%>" runat="server" CssClass="bbos_blue" Text="<%$ Resources:Global, Icon %>" />
          <span>
            <asp:Image ID="Icon" runat="server" /></span>
        </li>

        <li class="list-group-item d-flex justify-content-between align-items-center">
          <asp:Label for="<%= lblPrivate.ClientID%>" runat="server" CssClass="bbos_blue" Text="<%$ Resources:Global,Private %>" />
          <span>
            <asp:Label ID="lblPrivate" runat="server" CssClass="blacktext" /></span>
        </li>
        <%--
        <li class="list-group-item d-flex justify-content-between align-items-center">
          <asp:Label for="<%= lblCreatedBy.ClientID%>" runat="server" CssClass="bbos_blue" Text="<%$ Resources:Global,CreatedBy%>" />
          <span>
            <asp:Label ID="lblCreatedBy" runat="server" CssClass="blacktext" />
            <br />
            <asp:Label ID="lblCreatedByLocation" runat="server" CssClass="blacktext" />
          </span>
        </li>
        --%>
        <li class="list-group-item d-flex justify-content-between align-items-center" id="trLastUpdatedBy" runat="server">
          <asp:Label for="<%= lblLastUpdatedBy.ClientID%>" runat="server" CssClass="bbos_blue" Text="<%$ Resources:Global,LastUpdatedBy%>" />
          <span>
            <asp:Label ID="lblLastUpdatedBy" runat="server" CssClass="blacktext" />
            <br />
            <asp:Label ID="lblLastUpdatedByLocation" runat="server" CssClass="blacktext" /></span>
        </li>
      </ul>
    </div>
  </div>

  <div class="bbs-card-bordered">
    <div class="bbs-card-header tw-flex tw-gap-3 tw-justify-between" style="position: sticky; top: 44px">
      <h5>
        <asp:Label ID="lblRecordCount" runat="server" />
        &nbsp;&nbsp;|&nbsp;
        <span id="lblSelectedCount"></span>
      </h5>

      <div class="bbsButton-group-nowrap">

        <asp:LinkButton ID="btnRemove" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnRemove_Click" data-bs-toggle="tooltip" data-bs-title="<%$Resources:Global, RemoveFromWatchdogGroup %>">
          <span class="msicon notranslate" aria-hidden="true" runat="server">delete</span>
        </asp:LinkButton>
        <asp:LinkButton ID="btnSubmitTES" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnSubmitTESOnClick" data-bs-toggle="tooltip" data-bs-title="<%$Resources:Global, RateCompany %>">
          <span class="msicon notranslate" aria-hidden="true" runat="server">thumb_up_off_alt</span>
        </asp:LinkButton>
        <asp:LinkButton ID="btnMap" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClientClick="displayMap();return false;" data-bs-toggle="tooltip" data-bs-title="<%$Resources:Global, ShowOnMap %>">
          <span class="msicon notranslate" aria-hidden="true" runat="server">location_on</span>
        </asp:LinkButton>
        <asp:LinkButton ID="btnReports" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnReports_Click" data-bs-toggle="tooltip" data-bs-title="<%$Resources:Global, btnReports %>">
          <span class="msicon notranslate" aria-hidden="true" runat="server">download</span>
        </asp:LinkButton>
        <asp:LinkButton ID="btnExportData" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnExportData_Click" data-bs-toggle="tooltip" data-bs-title="<%$Resources:Global, btnExportData %>">
          <span class="msicon notranslate" aria-hidden="true" runat="server">export_notes</span>
        </asp:LinkButton>
        <asp:LinkButton ID="btnAnalyzeCompanies" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnAnalyzeCompanies_Click" data-bs-toggle="tooltip" data-bs-title="<%$Resources:Global, btnAnalyzeCompanies %>">
          <span class="msicon notranslate" aria-hidden="true" runat="server">frame_inspect</span>
        </asp:LinkButton>
        <asp:LinkButton ID="btnAddToWatchdog" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnAddToWatchdog_Click" OnClientClick="return IsCompanySelected();" data-bs-toggle="tooltip" data-bs-title="<%$ Resources:Global, btnAddToAnotherWatchdogList %>">
          <span class="msicon notranslate" aria-hidden="true" runat="server">playlist_add</span>
        </asp:LinkButton>
      </div>
    </div>
    <div class="bbs-card-body no-padding">
      <div class="table-responsive">
        <asp:GridView ID="gvCompanyList"
          AllowSorting="true"
          runat="server"
          AutoGenerateColumns="false"
          CssClass=" table  table-hover"
          GridLines="none"
          OnSorting="GridView_Sorting"
          OnRowDataBound="GridView_RowDataBound"
          SortField="comp_PRBookTradestyle"
          DataKeyNames="comp_CompanyID,comp_PRLastPublishedCSDate">

          <Columns>
            <asp:TemplateField HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center">
              <HeaderTemplate>
                <!--% =Resources.Global.Select%-->
                <% =PageBase.GetCheckAllCheckbox("cbCompanyID", "setSelectedCount();")%>
              </HeaderTemplate>
              <ItemTemplate>
                <input type="checkbox" name="cbCompanyID" value="<%# Eval("comp_CompanyID") %>" <%# GetChecked((int)Eval("comp_CompanyID")) %> onclick="setSelectedCount();" />
              </ItemTemplate>
            </asp:TemplateField>

            <%--BBNumber Column--%>
            <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-left"
              DataField="comp_CompanyID" SortExpression="comp_CompanyID" />

            <%--Icons Column--%>
            <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-nowrap vertical-align-top" ItemStyle-CssClass="text-nowrap text-right">
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
                <asp:Label ID="lblCompanyDetails" runat="server" Visible="false"><%# Eval("comp_PRBookTradestyle") %></asp:Label>
                <asp:Literal ID="litLegalName" runat="server" Text='<%# PageBase.ParenWrap(Eval("comp_PRLegalName"), true)%>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" HeaderStyle-CssClass="text-nowrap vertical-align-top" DataField="CityStateCountryShort"
              SortExpression="CountryStAbbrCity" />

            <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-left vertical-align-top">
              <HeaderTemplate>
                <% =PageControlBaseCommon.GetIndustryTypeHeader(_oUser) %>
              </HeaderTemplate>

              <ItemTemplate>
                <%# PageControlBaseCommon.GetIndustryTypeData((string)Eval("CompanyType"), (string)Eval("IndustryType"), Eval("comp_PRLocalSource"), _oUser)%>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:BoundField HeaderText="<%$ Resources:Global, Phone2 %>" ItemStyle-CssClass="text-left text-nowrap" HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" DataField="Phone" SortExpression="Phone" />

            <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" HeaderText="<%$ Resources:Global, Rating %>" ItemStyle-CssClass="text-nowrap">
              <ItemTemplate>
                <%# GetRatingCell(Eval("prra_RatingID"), Eval("prra_RatingLine"), Eval("IsHQRating"))%>
              </ItemTemplate>
            </asp:TemplateField>
          </Columns>
        </asp:GridView>
      </div>
    </div>
  </div>

  <div id="pnlRatingDef" style="display: none; width: 450px; height: auto; min-height: 300px; position: absolute; z-index: 100;" class="Popup">
    <div class="popup_header">
      <button type="button" class="close" data-bs-dismiss="modal" onclick="document.getElementById('pnlRatingDef').style.display='none';">&times;</button>
    </div>
    <span id="ltRatingDef"></span>
  </div>
  <br />
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
  <script type="text/javascript">
    function setSelectedCount() {
      setSelectedCountInternal("cbCompanyID", "lblSelectedCount");

      var selectedCompanyIDs = $.map($(':checkbox[name=cbCompanyID]:checked'), function (n, i) {
        return n.value;
      }).join(',');

      $('#<%=hidSelectedCompanyIDs.ClientID%>').attr('value', selectedCompanyIDs);
    }

    setSelectedCount();

    function IsCompanySelected() {
      if ($("input[type='checkbox'][name='cbCompanyID']:checked").length == 0) {
        displayErrorMessage("<%=Resources.Global.PleaseSelectACompany%>");
        return false;
      }

      return true;
    }

    </script>
</asp:Content>
