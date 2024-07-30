<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanyUpdates.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyUpdates" Title="Blue Book Services" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeaderMeister" Src="UserControls/CompanyDetailsHeaderMeister.ascx" %>
<%@ Register TagPrefix="bbos" TagName="Sidebar" Src="UserControls/Sidebar.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyHero" Src="UserControls/CompanyHero.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyBio" Src="UserControls/CompanyBio.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PrintHeader" Src="UserControls/PrintHeader.ascx" %>


<%@ Register TagPrefix="bbos" TagName="CompanyListing" Src="UserControls/CompanyListing.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<%@ Import Namespace="PRCo.BBOS.UI.Web" %>
<%@ Import Namespace="PRCo.EBB.BusinessObjects" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
  <script type="text/javascript">
</script>
</asp:Content>

<asp:Content ID="contentMain" ContentPlaceHolderID="contentMain" runat="server">
  <asp:Label ID="hidCompanyID" Visible="false" runat="server" />
  <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" Visible="false" />
</asp:Content>

<asp:Content ID="contentLeftSidebar" ContentPlaceHolderID="contentLeftSidebar" runat="server">
  <!-- Left nav bar  -->
  <bbos:Sidebar ID="ucSidebar" runat="server" MenuExpand="1" MenuPage="7" />

  <!-- Main  -->
  <main class="main-content tw-flex tw-flex-col tw-gap-y-4">
    <bbos:PrintHeader ID="ucPrintHeader" runat="server" Title='<% $Resources:Global, CompanyUpdatesSearch %>' />
    <bbos:CompanyHero ID="ucCompanyHero" runat="server" />
    <bbos:CompanyBio ID="ucCompanyBio" runat="server" />
    <bbos:CompanyDetailsHeaderMeister ID="ucCompanyDetailsHeaderMeister" runat="server" />
    <p class="page-heading"><%= Resources.Global.CompanyUpdatesSearch %></p>

    <%--
    Hiding old listing since this is on the company profile page
    PT - 5/11/2024 for BBOS 9.1
    --%>
    <bbos:CompanyListing ID="ucCompanyListing" runat="server" Visible="false" />

    <div class="container">
      <div class="row g-4">
        <%--Filter start --%>
        <div class="col-xs-12">
          <div class="bbs-card-bordered">
            <div class="bbs-card-header tw-flex tw-justify-between">
              <% =Resources.Global.CompanyUpdatesFilter %>
                <div class="tw-flex tw-gap-2">
                    <asp:LinkButton CssClass="bbsButton bbsButton-secondary filled small" ID="btnFilter" OnClick="btnFilterOnClick" runat="server">
                        <span class="msicon notranslate">filter_list</span>
                        <span><asp:Literal runat="server" Text="<%$ Resources:Global, Filter %>" /></span>
                    </asp:LinkButton>
                    <asp:LinkButton CssClass="bbsButton bbsButton-secondary filled small" ID="btnClear" OnClick="btnClear_Click" runat="server">
                        <span class="msicon notranslate">clear</span>
                        <span><asp:Literal runat="server" Text="<%$ Resources:Global, ClearCriteria %>" /></span>
                    </asp:LinkButton>
                </div>
            </div>
            <div class="bbs-card-body">
              <div class="container">
                <div class="row">
                  <div class="col-6 col-md-4">
                    <label for="txtDateFrom"><% =Resources.Global.FromDate %>:</label>
                    <div class="input-group mb-3">
                      <asp:TextBox ID="txtDateFrom" CssClass="form-control" aria-describedby="button-addon1" AutoCompleteType="None" tsiDate="true" tsiDisplayName="<%$ Resources:Global, FromDate %>" tsiRequired="true" runat="server" />
                      <button class="input-group-text" type="button" id="button-addon1" onclick="$('#<%=txtDateFrom.ClientID %>').focus();$('#<%=txtDateFrom.ClientID %>').click();">
                        <span class="msicon notranslate">calendar_month</span>
                      </button>
                      <cc1:CalendarExtender runat="server" ID="ceDatFrom" TargetControlID="txtDateFrom" />
                    </div>
                  </div>
                  <div class="col-6 col-md-4">
                    <label for="txtDateTo"><% =Resources.Global.ToDate %></label>
                    <div class="input-group mb-3">
                      <asp:TextBox ID="txtDateTo" CssClass="form-control" aria-describedby="button-addon2" AutoCompleteType="None" tsiDate="true" tsiDisplayName="<%$ Resources:Global, ToDate %>" tsiRequired="true" runat="server" />
                      <button class="input-group-text" type="button" id="button-addon2" onclick="$('#<%=txtDateTo.ClientID %>').focus();$('#<%=txtDateTo.ClientID %>').click();">
                        <span class="msicon notranslate">calendar_month</span>
                      </button>
                      <cc1:CalendarExtender runat="server" ID="ceDateTo" TargetControlID="txtDateTo" />
                    </div>
                  </div>
                  <div class="col-md-4 tw-flex tw-gap-2 tw-items-center">
                    <asp:CheckBox ID="cbKeyChangesOnly" runat="server" />
                    <label for="<%=cbKeyChangesOnly.ClientID%>"><% =Resources.Global.KeyChangesOnly %></label>

                    <%-- THIS DOES NOT WORK --%>
                    <a id="WhatIsKeyChanges" visible="false" runat="server" href="#" class="clr_blc" data-bs-trigger="hover" data-bs-html="true" style="color: #000;" data-bs-toggle="popover" data-bs-placement="bottom">
                      <img src="images/info_sm.png" />
                    </a>

                  </div>
                </div>
              </div>
            </div>
          </div>


        </div>
        <%--Filter End --%>
        <%-- Table Start--%>
        <div class="col-xs-12">
          <div class="bbs-card-bordered">
            <div class="bbs-card-header tw-flex tw-justify-between">
              <h5><% =Resources.Global.CompanyUpdates %></h5>
              <div class="tw-flex tw-gap-2">
                <asp:Label ID="lblRatingNumeralDefinitions" CssClass="bbsButton bbsButton-secondary filled small" Text="<%$ Resources:Global, AllRatingDefinitions %>" runat="server" />
                <asp:LinkButton CssClass="bbsButton bbsButton-secondary filled small" ID="btnCompanyUpdateReport" OnClick="btnCompanyUpdateReportOnClick" runat="server">
                  <span class="msicon notranslate">download</span>
                  <span><asp:Literal runat="server" Text="<%$ Resources:Global, Download %>" /></span>
                </asp:LinkButton>
              </div>
            </div>
            <div class="bbs-card-body no-padding overflow-auto">
              <asp:GridView ID="gvCompanyUpdates"
                AllowSorting="true"
                runat="server"
                AutoGenerateColumns="false"
                CssClass="table  table-hover "
                GridLines="None"
                OnSorting="GridView_Sorting"
                OnRowDataBound="GridView_RowDataBound">
                <Columns>
                  <asp:TemplateField HeaderStyle-Width="20%" HeaderText="<%$ Resources:Global, DateOfUpdate %>" HeaderStyle-CssClass="tw-font-semibold text-nowrap explicitlink" SortExpression="prcs_PublishableDate" ItemStyle-VerticalAlign="Top" ItemStyle-CssClass="text-left">
                    <ItemTemplate>
                      <%# UIUtils.GetStringFromDate(Eval("prcs_PublishableDate"))%>
                    </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderStyle-Width="20%" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="tw-font-semibold text-nowrap text-center explicitlink" HeaderText="<%$ Resources:Global, Key %>" SortExpression="prcs_KeyFlag" ItemStyle-VerticalAlign="Top">
                    <ItemTemplate>
                      <%# UIUtils.GetStringFromBool(Eval("prcs_KeyFlag"))%>
                    </ItemTemplate>
                  </asp:TemplateField>

                  <asp:TemplateField HeaderStyle-Width="60%" HeaderText="<%$ Resources:Global, UpdateItem %>" HeaderStyle-CssClass="tw-font-semibold text-nowrap">
                    <ItemTemplate>
                      <%# Eval("ItemText") %>
                    </ItemTemplate>
                  </asp:TemplateField>
                </Columns>
              </asp:GridView>
            </div>
          </div>
        </div>

        <%-- Table End --%>
      </div>
    </div>
    <br />
    <asp:Panel ID="pnlRatingNumeralDefinition" Style="display: none; height: 500px;" CssClass="Popup" Width="350px" runat="server" />
    <cc1:PopupControlExtender ID="pceRatingNumeralDefinition" runat="server" 
      TargetControlID="lblRatingNumeralDefinitions" 
      PopupControlID="pnlRatingNumeralDefinition" 
      OffsetX="-100" Position="bottom" />
    <cc1:DynamicPopulateExtender ID="dpeRatingNumeralDefinition"
      runat="server" TargetControlID="pnlRatingNumeralDefinition" 
      PopulateTriggerControlID="lblRatingNumeralDefinitions" 
      ServiceMethod="GetRatingNumeralsDefinitions" 
      ServicePath="AJAXHelper.asmx" 
      CacheDynamicResults="true" />
  </main>
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">
  <script language="javascript" type="text/javascript">
    function RatingNumeralDefinitionLoad() {
      var popup = $find('pceRatingNumeralDefinition');
      if (!popup) return;

      popup.add_populated(function () {
        //EnableRowHighlight(document.getElementById('tblAllRatingNumeralDefinitions'));
      });
    }

    Sys.Application.add_load(RatingNumeralDefinitionLoad);
    btnSubmitOnEnter = document.getElementById('<% =btnFilter.ClientID %>');
  </script>
</asp:Content>
