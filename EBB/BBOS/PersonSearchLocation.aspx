<%@ Page Title="" Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="PersonSearchLocation.aspx.cs" Inherits="PRCo.BBOS.UI.Web.PersonSearchLocation" MaintainScrollPositionOnPostback="true" %>

<%@ Register Src="UserControls/PersonSearchCriteriaControl.ascx" TagName="PersonSearchCriteriaControl" TagPrefix="uc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
  <style>
    .checkBoxListWrap tr td {
      vertical-align: top;
      width: 33%;
    }

    .checkBoxListWrap input {
    }

    .checkBoxListWrap label {
      position: relative;
      float: left;
      margin-left: 25px;
    }

    input[type="checkbox"], input[type="radio"] {
      margin-right: 4px;
    }

    .main-content-old {
      width: 100%;
    }
  </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
  <asp:HiddenField ID="hPageView" runat="server" Value="0" />

  <asp:Panel ID="pnlSearch" DefaultButton="btnSearch" runat="server" CssClass="tw-px-4">
    <div class="row g-3">
      <%--Buttons--%>
      <div class="tw-flex tw-flex-wrap tw-gap-2 tw-justify-end">

        <asp:LinkButton ID="btnLoadSearch" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClientClick="return confirmOverrwrite('LoadSearch')" OnClick="btnLoadSearch_Click">
                    <span class="msicon notranslate">input</span>
                    <span><asp:Literal runat="server" Text="<%$ Resources:Global, LoadSearch %>" /></span>
        </asp:LinkButton>

        <asp:LinkButton ID="btnClearAllCriteria" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnClearAllCriteria_Click">
                    <span class="msicon notranslate">clear_all</span>
                    <span><asp:Literal runat="server" Text="<%$ Resources:Global, ClearAll %>" /></span>
        </asp:LinkButton>
        <asp:LinkButton ID="btnSaveSearch" runat="server" CssClass="bbsButton bbsButton-secondary filled" OnClick="btnSaveSearch_Click">
                    <span class="msicon notranslate">saved_search</span>
                    <span><asp:Literal runat="server" Text="<%$ Resources:Global, SaveSearch %>" /></span>
        </asp:LinkButton>

        <asp:LinkButton ID="btnSearch" runat="server" CssClass="bbsButton bbsButton-primary" OnClick="btnSearch_Click">
                    <span class="msicon notranslate">search</span>
                    <span><asp:Literal runat="server" Text="<%$ Resources:Global, Search %>" /></span>
        </asp:LinkButton>
      </div>

      <div class=" bbslayout_splitView tw-gap-3 bbslayout_second_onTop">
        <div class="bbslayout_first_split">
          <%--Search Form--%>
          <div>
            <%--Listing Country--%>
            <asp:Panel ID="trListingCountry" runat="server" CssClass="bbs-card-bordered">
              <div class="bbs-card-header tw-flex tw-justify-between">
                <h5><%=Resources.Global.ListingCountry %>
                </h5>
                <asp:LinkButton ID="btnClearCriteria" runat="server" CssClass="bbsButton bbsButton-secondary filled small" OnClick="btnClearCriteria_Click">
                     <span class="msicon notranslate">clear</span>
                    <span><asp:Literal runat="server" Text="<%$ Resources:Global, ClearThisCriteria %>" /></span>
                </asp:LinkButton>
              </div>
              <div class="bbs-card-body">
                <p>
                  <asp:CheckBoxList ID="cblCountryNA" runat="server" AutoPostBack="True" RepeatColumns="5" RepeatDirection="Horizontal"
                    CssClass="nowraptd_wraplabel norm_lbl" />
                </p>
                <p>
                  <button type="button" id="cnView" class="bbsButton bbsButton-secondary filled small" onclick="javascript:ToggleCN(true);" runat="server">
                    <i class="fa fa-caret-right" aria-hidden="true" runat="server" />&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ViewAllCountries %>" />
                  </button>
                  <button type="button" id="cnHide" class="bbsButton bbsButton-secondary filled small" onclick="javascript:ToggleCN(false);" runat="server" style="display: none">
                    <i class="fa fa-caret-up" aria-hidden="true" runat="server" />&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, HideMostCountries %>" />
                  </button>

                  <br />
                  <asp:Label CssClass="small" ID="countryRegions" runat="server">
                        <span class="clr_blu small fontbold"><%=Resources.Global.Show %>:&nbsp;</span>
                        <a href="javascript:showCountries('CA', true);" class="clr_blu"><%=Resources.Global.CentralAmerica %></a> <span class="clr_blu">|</span>
                        <a href="javascript:showCountries('CR', true);" class="clr_blu"><%=Resources.Global.Caribbean %></a><span class="clr_blu">|</span>
                        <a href="javascript:showCountries('SA', true);" class="clr_blu"><%=Resources.Global.SouthAmerica %></a> <span class="clr_blu">|</span>
                        <a href="javascript:showCountries('EU', true);" class="clr_blu"><%=Resources.Global.Europe %></a> <span class="clr_blu">|</span>
                        <a href="javascript:showCountries('CSAME', true);" class="clr_blu"><%=Resources.Global.CentralSouthAsiaMiddleEast %></a> <span class="clr_blu">|</span>
                        <a href="javascript:showCountries('EAP', true);" class="clr_blu"><%=Resources.Global.EasternAsiaPacific %></a> <span class="clr_blu">|</span>
                        <a href="javascript:showCountries('AF', true);" class="clr_blu"><%=Resources.Global.Africa %></a> <span class="clr_blu"></span>
                        
                        <br />

                        <span class="clr_blu small fontbold"><%=Resources.Global.Hide %>:&nbsp;</span>
                        <a href="javascript:showCountries('CA', false);" class="clr_blu"><%=Resources.Global.CentralAmerica %></a> <span class="clr_blu">|</span>
                        <a href="javascript:showCountries('CR', false);" class="clr_blu"><%=Resources.Global.Caribbean %></a> <span class="clr_blu">|</span>
                        <a href="javascript:showCountries('SA', false);" class="clr_blu"><%=Resources.Global.SouthAmerica %></a> <span class="clr_blu">|</span>
                        <a href="javascript:showCountries('EU', false);" class="clr_blu"><%=Resources.Global.Europe %></a> <span class="clr_blu">|</span>
                        <a href="javascript:showCountries('CSAME', false);" class="clr_blu"><%=Resources.Global.CentralSouthAsiaMiddleEast %></a> <span class="clr_blu">|</span>
                        <a href="javascript:showCountries('EAP', false);" class="clr_blu"><%=Resources.Global.EasternAsiaPacific%></a> <span class="clr_blu">|</span>
                        <a href="javascript:showCountries('AF', false);" class="clr_blu"><%=Resources.Global.Africa %></a> <span class="clr_blu"></span>
                    </asp:Label>

                  <div id="CountryCA" style="margin-top: 10px;">
                    <span style="font-weight: bold;" class="clr_blu">
                      <asp:Literal ID="lblCA" runat="server" /></span>
                    <asp:CheckBoxList ID="cblCountryCA" runat="server" AutoPostBack="True" RepeatColumns="3"
                      RepeatDirection="Horizontal" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel" />
                  </div>

                  <div id="CountryCR" style="margin-top: 10px;">
                    <span style="font-weight: bold;" class="clr_blu">
                      <asp:Literal ID="lblCR" runat="server" /></span>
                    <asp:CheckBoxList ID="cblCountryCR" runat="server" AutoPostBack="True" RepeatColumns="3"
                      RepeatDirection="Horizontal" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel" />
                  </div>

                  <div id="CountrySA" style="margin-top: 10px;">
                    <span style="font-weight: bold;" class="clr_blu">
                      <asp:Literal ID="lblSA" runat="server" /></span>
                    <asp:CheckBoxList ID="cblCountrySA" runat="server" AutoPostBack="True" RepeatColumns="3"
                      RepeatDirection="Horizontal" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel" />
                  </div>

                  <div id="CountryEU" style="margin-top: 10px;">
                    <span style="font-weight: bold;" class="clr_blu">
                      <asp:Literal ID="lblEU" runat="server" /></span>
                    <asp:CheckBoxList ID="cblCountryEU" runat="server" AutoPostBack="True" RepeatColumns="3"
                      RepeatDirection="Horizontal" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel" />
                  </div>

                  <div id="CountryCSAME" style="margin-top: 10px;">
                    <span style="font-weight: bold;" class="clr_blu">
                      <asp:Literal ID="lblCSAME" runat="server" /></span>
                    <asp:CheckBoxList ID="cblCountryCSAME" runat="server" AutoPostBack="True" RepeatColumns="3"
                      RepeatDirection="Horizontal" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel" />
                  </div>

                  <div id="CountryEAP" style="margin-top: 10px;">
                    <span style="font-weight: bold;" class="clr_blu">
                      <asp:Literal ID="lblEAP" runat="server" /></span>
                    <asp:CheckBoxList ID="cblCountryEAP" runat="server" AutoPostBack="True" RepeatColumns="3"
                      RepeatDirection="Vertical" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel" />
                  </div>

                  <div id="CountryAF" style="margin-top: 10px;">
                    <span style="font-weight: bold;" class="clr_blu">
                      <asp:Literal ID="lblAF" runat="server" /></span>
                    <asp:CheckBoxList ID="cblCountryAF" runat="server" AutoPostBack="True" RepeatColumns="3"
                      RepeatDirection="Horizontal" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel" />
                  </div>
                </p>
              </div>
            </asp:Panel>

            <%--Listing State/Province--%>
            <asp:Panel ID="trListingStateProvince" runat="server" CssClass="bbs-card-bordered">
              <div class="bbs-card-header tw-flex tw-justify-between">
                <h5><%=Resources.Global.ListingStateProvince %>
                </h5>
                <p class="tw-text-text-secondary tw-text-sm">
                  <%= Resources.Global.StateSearchText %>
                </p>
              </div>
              <div class="bbs-card-body">
                <div class="col-md-12">
                  <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                    <ContentTemplate>
                      <asp:Panel ID="pnlStatesFor_1" runat="server" Visible="false">
                        <asp:Label ID="lblCountryName_1" runat="server" Style="font-weight: bold;" CssClass="clr_blu"></asp:Label>

                        <br />

                        <asp:Label CssClass="small" runat="server">
                                <span class="clr_blu small fontbold"><%= Resources.Global.Select%>:</span>
                                <a href="javascript:toggleRegion('7', true)" class="clr_blu"><%= Resources.Global.Northeast %></a> <span class="clr_blu">|</span>
                                <a href="javascript:toggleRegion('6', true)" class="clr_blu"><%= Resources.Global.Southeast %></a> <span class="clr_blu">|</span>
                                <a href="javascript:toggleRegion('4', true)" class="clr_blu"><%= Resources.Global.Midwest %></a> <span class="clr_blu">|</span>
                                <a href="javascript:toggleRegion('5', true)" class="clr_blu"><%= Resources.Global.South %></a> <span class="clr_blu">|</span>
                                <a href="javascript:toggleRegion('2', true)" class="clr_blu"><%= Resources.Global.Northwest %></a> <span class="clr_blu">|</span>
                                <a href="javascript:toggleRegion('3', true)" class="clr_blu"><%= Resources.Global.Southwest %></a>

                                <br />

                                <span class="clr_blu small fontbold"><%= Resources.Global.Deselect%>:</span>
                                <a href="javascript:toggleRegion('7', false)" class="clr_blu"><%= Resources.Global.Northeast %></a> <span class="clr_blu">|</span>
                                <a href="javascript:toggleRegion('6', false)" class="clr_blu"><%= Resources.Global.Southeast %></a> <span class="clr_blu">|</span>
                                <a href="javascript:toggleRegion('4', false)" class="clr_blu"><%= Resources.Global.Midwest %></a> <span class="clr_blu">|</span>
                                <a href="javascript:toggleRegion('5', false)" class="clr_blu"><%= Resources.Global.South %></a>  <span class="clr_blu">|</span>
                                <a href="javascript:toggleRegion('2', false)" class="clr_blu"><%= Resources.Global.Northwest %></a> <span class="clr_blu">|</span>
                                <a href="javascript:toggleRegion('3', false)" class="clr_blu"><%= Resources.Global.Southwest %></a>
                        </asp:Label>

                        <br />

                        <asp:CheckBoxList ID="cblStatesFor_1" runat="server" Style="table-layout: fixed;" AutoPostBack="true" RepeatColumns="3"
                          RepeatDirection="Vertical" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel" />
                      </asp:Panel>

                      <asp:Panel ID="pnlStatesFor_2" runat="server" Visible="false">
                        <asp:Label ID="lblCountryName_2" runat="server" Style="font-weight: bold;" CssClass="clr_blu"></asp:Label><br />
                        <asp:CheckBoxList ID="cblStatesFor_2" runat="server" Style="table-layout: fixed;" AutoPostBack="true" RepeatColumns="3"
                          RepeatDirection="Vertical" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel">
                        </asp:CheckBoxList>
                      </asp:Panel>
                      <asp:Panel ID="pnlStatesFor_3" runat="server" Visible="false">
                        <asp:Label ID="lblCountryName_3" runat="server" Style="font-weight: bold;" CssClass="clr_blu"></asp:Label><br />
                        <asp:CheckBoxList ID="cblStatesFor_3" runat="server" Style="table-layout: fixed;" AutoPostBack="true" RepeatColumns="3"
                          RepeatDirection="Vertical" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel" />
                      </asp:Panel>
                    </ContentTemplate>
                    <Triggers>
                      <asp:AsyncPostBackTrigger ControlID="cblCountryNA" EventName="SelectedIndexChanged" />
                    </Triggers>
                  </asp:UpdatePanel>
                </div>
              </div>
            </asp:Panel>

            <%--Listing City/Country/market/postal/radius--%>
            <div class="bbs-card-bordered">

              <div class="bbs-card-body">

                <div class="row nomargin_lr">
                  <div class="col-md-2 clr_blu">
                    <%= Resources.Global.ListingCity %>:
                  </div>
                  <div class="col-md-6">
                    <asp:TextBox ID="txtListingCity" runat="server" CssClass="form-control" AutoPostBack="True" autocomplete="off"></asp:TextBox>
                    <cc1:AutoCompleteExtender ID="aceListingCity" runat="server"
                      TargetControlID="txtListingCity"
                      BehaviorID="aceListingCity"
                      ServiceMethod="GetCityCompletionList"
                      ServicePath="AJAXHelper.asmx"
                      CompletionInterval="100"
                      MinimumPrefixLength="2"
                      CompletionSetCount="20"
                      CompletionListCssClass="AutoCompleteFlyout"
                      CompletionListItemCssClass="AutoCompleteFlyoutItem"
                      CompletionListHighlightedItemCssClass="AutoCompleteFlyoutHilightedItem"
                      CompletionListElementID="pnlCityAutoComplete"
                      OnClientPopulated="aceCityPopulated"
                      OnClientPopulating="aceCityPopulating"
                      OnClientItemSelected="aceCitySelected"
                      DelimiterCharacters="|"
                      EnableCaching="False"
                      UseContextKey="True"
                      ContextKey=""
                      FirstRowSelected="true">
                    </cc1:AutoCompleteExtender>
                  </div>
                </div>

                <asp:Panel ID="pnlTerminalMarket" runat="server">
                  <div class="row nomargin_lr">
                    <div class="col-md-2 clr_blu">
                      <asp:Label ID="lblTerminalMarket" runat="server"><%= Resources.Global.TerminalMarket %>:</asp:Label>
                    </div>
                    <div class="col-md-10">
                      <asp:Panel ID="pnlTMButtons" runat="server">
                        <div id="tmView" class="bbsButton bbsButton-secondary filled" onclick="javascript:ToggleTM(true);" runat="server">
                          <i class="fa fa-caret-right" aria-hidden="true" runat="server" />&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ShowTerminalMarkets %>" />
                        </div>

                        <div id="tmHide" class="bbsButton bbsButton-secondary filled" onclick="javascript:ToggleTM(false);" runat="server" style="display: none;">
                          <i class="fa fa-caret-right" aria-hidden="true" runat="server" />&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, HideTerminalMarkets %>" />
                        </div>
                      </asp:Panel>

                      <asp:UpdatePanel ID="UpdatePanel4" runat="server">
                        <ContentTemplate>
                          <asp:CheckBoxList ID="cblTerminalMarket" runat="server" Font-Size="Smaller" AutoPostBack="True" RepeatColumns="2"
                            RepeatDirection="Horizontal" CssClass="checkboxlist-2col fontsize13 nowraptd_wraplabel" />
                        </ContentTemplate>
                        <Triggers>
                          <asp:AsyncPostBackTrigger ControlID="cblCountryNA" EventName="SelectedIndexChanged" />
                          <asp:AsyncPostBackTrigger ControlID="cblStatesFor_1" EventName="SelectedIndexChanged" />
                          <asp:AsyncPostBackTrigger ControlID="cblStatesFor_2" EventName="SelectedIndexChanged" />
                          <asp:AsyncPostBackTrigger ControlID="cblStatesFor_3" EventName="SelectedIndexChanged" />
                        </Triggers>
                      </asp:UpdatePanel>
                    </div>
                  </div>
                </asp:Panel>

                <div class="row nomargin_lr">
                  <div class="col-md-2 clr_blu">
                    <%= Resources.Global.PostalCode %>:
                  </div>
                  <div class="col-md-2">
                    <asp:TextBox ID="txtPostalCode" runat="server" CssClass="form-control" AutoPostBack="true"></asp:TextBox>
                  </div>
                  <div class="col-md-8">
                    <span class="bbos_blue annotation">
                      <asp:Label ID="lblRadiusSearchText" runat="server"></asp:Label>
                      <asp:HyperLink ID="btnLookupPostalCode" CssClass="bbsButton bbsButton-secondary filled" runat="server" Target="_blank" Font-Size="Smaller">
                        <i class="fa fa-caret-right" aria-hidden="true" runat="server" />&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, LookupPostalCode %>" />
                      </asp:HyperLink>
                    </span>
                  </div>
                </div>

                <div id="trRadius" class="row nomargin_lr" disabled>
                  <div class="col-md-2 clr_blu">
                    <%= Resources.Global.WithinRadius %>:
                  </div>
                  <div class="col-md-2">
                    <asp:TextBox ID="txtRadius" runat="server" CssClass="form-control" MaxLength="4" AutoPostBack="True"></asp:TextBox>
                    <cc1:FilteredTextBoxExtender ID="ftbeRadius" runat="server" TargetControlID="txtRadius" FilterType="Numbers" />
                  </div>
                  <div class="col-md-8">
                    <asp:Label ID="lblMilesOf" runat="server" CssClass="bbos_blue" />
                    <asp:RadioButtonList ID="rblRadiusSearchType" runat="server" AutoPostBack="True" RepeatColumns="2" RepeatDirection="Horizontal" RepeatLayout="Flow" />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="bbslayout_second_split">
          <%--Selected Criteria--%>
          <div>

            <asp:UpdatePanel ID="UpdatePanel1" runat="server">
              <ContentTemplate>
                <uc1:PersonSearchCriteriaControl ID="ucSearchCriteriaControl" runat="server" />
              </ContentTemplate>
              <Triggers>
                <asp:AsyncPostBackTrigger ControlID="cblCountryNA" EventName="SelectedIndexChanged" />
                <asp:AsyncPostBackTrigger ControlID="txtListingCity" EventName="TextChanged" />
                <asp:AsyncPostBackTrigger ControlID="cblTerminalMarket" EventName="SelectedIndexChanged" />
                <asp:AsyncPostBackTrigger ControlID="txtPostalCode" EventName="TextChanged" />
                <asp:AsyncPostBackTrigger ControlID="rblRadiusSearchType" EventName="SelectedIndexChanged" />
                <asp:AsyncPostBackTrigger ControlID="cblStatesFor_1" EventName="SelectedIndexChanged" />
                <asp:AsyncPostBackTrigger ControlID="cblStatesFor_2" EventName="SelectedIndexChanged" />
                <asp:AsyncPostBackTrigger ControlID="cblStatesFor_3" EventName="SelectedIndexChanged" />
                <asp:AsyncPostBackTrigger ControlID="txtRadius" EventName="TextChanged" />
              </Triggers>
            </asp:UpdatePanel>



          </div>
        </div>
      </div>




    </div>
  </asp:Panel>

  <%--<div id="pnlCityAutoComplete" style="z-index: 5000;"></div>--%>
  <br />
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptSection" runat="server">
  <script type="text/javascript">
    function showCountries(region, display) {
      if (display) {
        document.getElementById('Country' + region).style.display = "";
      } else {
        document.getElementById('Country' + region).style.display = "none";
      }
    }

    function ToggleTM(display) {
      if (display) {
        document.getElementById("contentMain_UpdatePanel4").style.display = "";
        document.getElementById("<%= tmHide.ClientID%>").style.display = "";
        document.getElementById("<%= tmView.ClientID%>").style.display = "none";
      } else {
        document.getElementById("contentMain_UpdatePanel4").style.display = "none";
        document.getElementById("<%= tmHide.ClientID%>").style.display = "none";
        document.getElementById("<%= tmView.ClientID%>").style.display = "";
      }
    }

    function ToggleCN(display) {
      showCountries('CA', display);
      showCountries('CR', display);
      showCountries('SA', display);
      showCountries('EU', display);
      showCountries('CSAME', display);
      showCountries('EAP', display);
      showCountries('AF', display);

      if (display) {
        document.getElementById("<%= cnHide.ClientID%>").style.display = "";
        document.getElementById("<%= cnView.ClientID%>").style.display = "none";
      } else {
        document.getElementById("<%= cnHide.ClientID%>").style.display = "none";
        document.getElementById("<%= cnView.ClientID%>").style.display = "";
      }
    }

    function checkForToggle() {
      showCountries('CA', false);
      showCountries('CR', false);
      showCountries('SA', false);
      showCountries('EU', false);
      showCountries('CSAME', false);
      showCountries('EAP', false);
      showCountries('AF', false);

      if (IsItemSelected("ctl00$contentMain$cblCountryCA")) {
        showCountries('CA', true);
      }
      if (IsItemSelected("ctl00$contentMain$cblCountryCR")) {
        showCountries('CR', true);
      }
      if (IsItemSelected("ctl00$contentMain$cblCountrySA")) {
        showCountries('SA', true);
      }
      if (IsItemSelected("ctl00$contentMain$cblCountryEU")) {
        showCountries('EU', true);
      }
      if (IsItemSelected("ctl00$contentMain$cblCountryCSAME")) {
        showCountries('CSAME', true);
      }
      if (IsItemSelected("ctl00$contentMain$cblCountryEAP")) {
        showCountries('EAP', true);
      }
      if (IsItemSelected("ctl00$contentMain$cblCountryAF")) {
        showCountries('AF', true);
      }
    }

    function IsItemSelected(szPrefix) {
      var oCheckboxes = document.body.getElementsByTagName("input");
      for (var i = 0; i < oCheckboxes.length; i++) {
        if ((oCheckboxes[i].type == "checkbox") &&
          (oCheckboxes[i].name.indexOf(szPrefix) == 0)) {

          if (oCheckboxes[i].checked) {
            return true;
          }
        }
      }

      return false;
    }

    Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(checkForToggle);

    btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');
    ToggleTM(false);
    function refreshCriteria() {
            <%=ClientScript.GetPostBackEventReference(UpdatePanel1, "")%>;
    }
  </script>
</asp:Content>
