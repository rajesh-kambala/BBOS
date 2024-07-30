<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserListEdit.aspx.cs" Inherits="PRCo.BBOS.UI.Web.UserListEdit" MasterPageFile="~/BBOS.Master" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Import Namespace="TSI.Utils" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
  <script type="text/javascript">
    function togglePrivate() {
      if (document.getElementById("<% =PinAvailable.ClientID %>").value == "false") {
        return;
      }
    }
    </script>
  <style>
    .main-content-old {
      max-width: 100%;
      width: 100%;
    }
  </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
  <asp:HiddenField ID="hidUserListID" runat="server" Value="0" />
  <asp:HiddenField ID="hidCompanyIDs" runat="server" Value="" />
  <asp:HiddenField ID="hidListType" runat="server" Value="" />
  <input type="hidden" id="PinAvailable" runat="server" />

  <div class="form-group mar_top">
    <div class="row">
      <div class="col-md-2">
        <asp:Label for="<%= txtListName.ClientID%>" runat="server" CssClass="bbos_blue" Text="<%$ Resources:Global,Name_Cap %>" />
      </div>
      <div class="col-md-5 d-inline">
        <asp:TextBox ID="txtListName" runat="server" Columns="50" MaxLength="50" tsiRequired="true"
          tsiDisplayName="<%$ Resources:Global, Name_Cap %>" CssClass="form-control" />
      </div>
      <div class="col-1 d-inline">
          <% =PageBase.GetRequiredFieldIndicator() %>
      </div>
    </div>
    <div class="row mar_top_5">
      <div class="col-md-2">
        <asp:Label for="<%= txtListDescription.ClientID%>" runat="server" CssClass="bbos_blue" Text="<%$ Resources:Global, Description %>" />
      </div>
      <div class="col-md-5">
        <!-- Note: OnKeyPress added for maxlength - this attribute does not apply to textmode=multiline -->
        <asp:TextBox ID="txtListDescription" runat="server" TextMode="multiLine" Columns="40"
          Rows="3" MaxLength="500" onkeypress="ValidateTextAreaLength(this, 500);" CssClass="form-control"></asp:TextBox>
      </div>
    </div>

    <div class="row mar_top_5">
      <div class="col-md-2">
        <asp:Label for="<%= rbIcon.ClientID%>" runat="server" CssClass="bbos_blue" Text="<%$ Resources:Global, Icon %>" />
      </div>
      <div class="col-md-9">
        &nbsp;<input type="radio" name="rbIcon" id="rbIconNone" value="" <% =GetIconChecked("") %> />
        <label for="rbIconNone">
          <%=Resources.Global.None %>
        </label>

        <asp:Repeater ID="repIcon" runat="server">
          <ItemTemplate>
            <input type="radio" name="rbIcon" id="rbIcon<%# Eval("Code") %>" value='<%# Eval("Code") %>' <%# GetIconChecked((string)Eval("Code")) %> />
            <label for="rbIcon<%# Eval("Code") %>">
              <img src="<%# UIUtils.GetImageURL((string)Eval("Code")) %>" alt="<%# Eval("Meaning") %>" />
            </label>
            &nbsp;&nbsp;
          </ItemTemplate>
        </asp:Repeater>
      </div>
    </div>

    <div class="row mar_top_5">
      <div class="col-md-2">
        <asp:Label for="<%= chkIsPrivate.ClientID%>" runat="server" CssClass="bbos_blue" Text="<%$ Resources:Global, Private %>" />
      </div>
      <div class="col-md-9">
        &nbsp;<asp:CheckBox ID="chkIsPrivate" onchange="togglePrivate();" runat="server" CssClass="space" />
        <%= Resources.Global.OnlyICanViewEditThis%>&nbsp;<%= Resources.Global.WatchdogList%>.&nbsp;&nbsp;<%= Resources.Global.Public%>&nbsp;<%= Resources.Global.WatchdogLists%>&nbsp;<%= Resources.Global.cannotbechangedtoprivate%>. 
      </div>
    </div>

    <div class="row mar_top_5">
      <div class="col-md-2">
        <asp:Label for="<%= lblCreatedBy.ClientID%>" runat="server" CssClass="bbos_blue" Text="<%$ Resources:Global, CreatedBy %>" />
      </div>
      <div class="col-md-9 form-inline">
        <asp:Label ID="lblCreatedBy" runat="server"></asp:Label>
        <br />
        <asp:Label ID="lblCreatedByLocation" runat="server"></asp:Label>
      </div>
    </div>
    <br />
  </div>


  <div class="bbs-card-bordered mt-3" ID="userListTableCard" runat="server" Visible="false">
    <div class="bbs-card-header">
      <h5>
        <asp:Label ID="lblRecordCount" runat="server" Visible="false" />&nbsp;&nbsp;|&nbsp;
        <span id="pnlRecordCnt" runat="server" visible="false">
          <span id="lblSelectedCount"></span>
        </span>
      </h5>
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
          DataKeyNames="comp_CompanyID">

          <Columns>
            <asp:TemplateField ItemStyle-CssClass="text-center vertical-align-top" HeaderStyle-CssClass="text-center vertical-align-top">
              <HeaderTemplate>
                <% =Resources.Global.Remove2 %>
                <br />
                <% =GetCheckAllCheckbox("cbCompanyID", "setSelectedCount();")%>
              </HeaderTemplate>
              <ItemTemplate>
                <input type="checkbox" name="cbCompanyID" value="<%# Eval("comp_CompanyID") %>" <%# GetChecked((int)Eval("comp_CompanyID")) %> onclick="setSelectedCount();" />
              </ItemTemplate>
            </asp:TemplateField>

            <%--BBNumber Column--%>
            <asp:BoundField HeaderText="<%$ Resources:Global, BBNumber %>" ItemStyle-CssClass="text-left vertical-align-top" HeaderStyle-CssClass="text-nowrap vertical-align-top"
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
              </ItemTemplate>
            </asp:TemplateField>

            <asp:BoundField HeaderText="<%$ Resources:Global, Location %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top text-left" DataField="CityStateCountryShort" SortExpression="CityStateCountryShort" />
            <asp:BoundField HeaderText="<%$ Resources:Global, Industry %>" ItemStyle-CssClass="text-left" HeaderStyle-CssClass="text-nowrap vertical-align-top text-left" DataField="IndustryType" SortExpression="IndustryType" />

            <%--Type/Industry Column--%>
            <asp:TemplateField HeaderStyle-CssClass="text-nowrap text-left vertical-align-top" ItemStyle-CssClass="text-left vertical-align-top" SortExpression="CompanyType">
              <HeaderTemplate>
                <asp:LinkButton ID="lbTypeIndustryColHeader" runat="server" Text='<%$ Resources:Global, Type %>' CommandName="Sort" CommandArgument="CompanyType" />
                &nbsp;
                <a id="popWhatIsIndustry" runat="server" class="tw-text-brand cursor_pointer" data-bs-html="true" data-bs-toggle="modal" data-bs-target="#pnlIndustry">
                  <span runat="server" class="msicon no-translate" title="<%$ Resources:Global, WhatIsThis %>">help</span>
                </a>
              </HeaderTemplate>

              <ItemTemplate>
                <%# Eval("CompanyType")%>
              </ItemTemplate>
            </asp:TemplateField>
          </Columns>
        </asp:GridView>

        <div id="pnlIndustry" class="modal fade" role="dialog">
          <div class="modal-dialog">
            <!-- Modal content-->
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-bs-dismiss="modal">&times;</button>
              </div>
              <div class="modal-body">
                <span class="sml_font">
                  <%= Resources.Global.IndustryHelp %>
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>



  <div class="tw-flex tw-gap-3 tw-justify-end tw-flex-wrap p-2 tw-bg-bg-secondary tw-border-t" style="position: sticky; bottom: 0">
    <asp:LinkButton ID="btnCancel" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnCancel_Click">
		    <span class="msicon notranslate" aria-hidden="true" runat="server">cancel</span>
      <asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
    </asp:LinkButton>
    <asp:LinkButton ID="btnSave" runat="server" CssClass="bbsButton bbsButton-primary filled" OnClick="btnSave_Click">
		    <span class="msicon notranslate" aria-hidden="true" runat="server">save</span>
      <asp:Literal runat="server" Text="<%$Resources:Global, Save %>" />
    </asp:LinkButton>
  </div>
  <br />
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptSection" runat="server">
  <script type="text/javascript">
    function setSelectedCount() {
      var szUserListID = getParameterByName('UserListID');
      if (szUserListID != "0" && szUserListID != "")
        setSelectedCountInternal("cbCompanyID", "lblSelectedCount");
    }

    setSelectedCount();
    togglePrivate();

    function getParameterByName(name, url) {
      if (!url) url = window.location.href;
      name = name.replace(/[\[\]]/g, "\\$&");
      var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
      if (!results) return null;
      if (!results[2]) return '';
      return decodeURIComponent(results[2].replace(/\+/g, " "));
    }
  </script>
</asp:Content>
