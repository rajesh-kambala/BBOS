<%@ Page Language="C#" MasterPageFile="~/BBOS.Master" AutoEventWireup="true" CodeBehind="CompanySearchLocation.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanySearchLocation" EnableEventValidation="false" MaintainScrollPositionOnPostback="true" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Src="UserControls/CompanySearchCriteriaControl.ascx" TagName="CompanySearchCriteriaControl" TagPrefix="uc1" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        function showCountries(region, display) {

            if (display) {
                document.getElementById('Country' + region).style.display = "";
            } else {
                document.getElementById('Country' + region).style.display = "none";
            }

            var hid = document.getElementById('contentMain_hid' + region);
            if (hid != null)
                hid.value = display;
        }

        function restoreCountries(region) {
            var display;
            var hid = document.getElementById('contentMain_hid' + region);

            if (hid != null)
                display = hid.value;
            else
                display = "false";

            if (display == "true") {
                document.getElementById('Country' + region).style.display = "";
            } else {
                document.getElementById('Country' + region).style.display = "none";
            }
        }

        function checkCountries(btn, region) {
            var cbs = document.querySelectorAll('[id ^= "contentMain_cblCountry' + region + '_"]');

            if($(btn).prop('checked') == true)
                Array.prototype.forEach.call(cbs, callback);
            else
                Array.prototype.forEach.call(cbs, callback2);

            refreshCriteria();

            function callback(element, iterator) {
                $(element).prop('checked', true);
            }
            function callback2(element, iterator) {
                $(element).prop('checked', false);
            }
        }

        function ToggleTM(display) {
            if (display) {
                document.getElementById("<%=UpdatePanel4.ClientID%>").style.display = "";

                if (document.getElementById("<%=tmHide.ClientID%>") != null) {
                    document.getElementById("<%=tmHide.ClientID%>").style.display = "";
                }

                if (document.getElementById("<%=tmView.ClientID%>") != null) {
                    document.getElementById("<%=tmView.ClientID%>").style.display = "none";
                }
            }
            else {
                document.getElementById("<%=UpdatePanel4.ClientID%>").style.display = "none";

                if (document.getElementById("<%=tmHide.ClientID%>") != null) {
                    document.getElementById("<%=tmHide.ClientID%>").style.display = "none";
                }

                if (document.getElementById("<%=tmView.ClientID%>") != null) {
                    document.getElementById("<%=tmView.ClientID%>").style.display = "";
                }
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
                document.getElementById("<%=cnHide.ClientID%>").style.display = "";
                document.getElementById("<%=cnView.ClientID%>").style.display = "none";
            } else {
                document.getElementById("<%=cnHide.ClientID%>").style.display = "none";
                document.getElementById("<%=cnView.ClientID%>").style.display = "";
            }
        }

        function checkForToggle() {
            restoreCountries('CA');
            restoreCountries('CR');
            restoreCountries('SA');
            restoreCountries('EU');
            restoreCountries('CSAME');
            restoreCountries('EAP');
            restoreCountries('AF');

            if (IsItemSelected("<%=cblCountryCA.ClientID%>")) {
                showCountries('CA', true);
            }
            if (IsItemSelected("<%=cblCountryCR.ClientID%>")) {
                showCountries('CR', true);
            }
            if (IsItemSelected("<%=cblCountrySA.ClientID%>")) {
                showCountries('SA', true);
            }
            if (IsItemSelected("<%=cblCountryEU.ClientID%>")) {
                showCountries('EU', true);
            }
            if (IsItemSelected("<%=cblCountryCSAME.ClientID%>")) {
                showCountries('CSAME', true);
            }
            if (IsItemSelected("<%=cblCountryEAP.ClientID%>")) {
                showCountries('EAP', true);
            }

            if (IsItemSelected("<%=cblCountryAF.ClientID%>")) {
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
    </script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <asp:HiddenField ID="hPageView" runat="server" Value="0" />

    <asp:Panel ID="pnlSearch" DefaultButton="btnSearch" runat="server">
        <div class="row nomargin panels_box">
            <div class="col-md-3 col-sm-3 col-xs-12 nopadding">
                <%--Search Criteria--%>
                <div class="col-md-12 nopadding">
                    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                        <ContentTemplate>
                            <uc1:CompanySearchCriteriaControl ID="ucCompanySearchCriteriaControl" runat="server" />
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="cblCountryNA" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cblCountryCA" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cblCountryCR" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cblCountrySA" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cblCountryEU" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cblCountryCSAME" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cblCountryEAP" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cblCountryAF" EventName="SelectedIndexChanged" />

                            <asp:AsyncPostBackTrigger ControlID="rblIndustryType" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="txtListingCity" EventName="TextChanged" />
                            <%--<asp:AsyncPostBackTrigger ControlID="txtListingCounty" EventName="TextChanged" />--%>
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

                <%--Buttons--%>
                <div class="col-md-12 nopadding">
                    <div class="search_crit">
                        <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn gray_btn" OnClick="btnSearch_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Search %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnClearCriteria" runat="server" CssClass="btn gray_btn" OnClick="btnClearCriteria_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ClearThisCriteria %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnClearAllCriteria" runat="server" CssClass="btn gray_btn" OnClick="btnClearAllCriteria_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ClearAllCriteria %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnSaveSearch" runat="server" CssClass="btn gray_btn" OnClick="btnSaveSearch_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, SaveSearchCriteria %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnLoadSearch" runat="server" CssClass="btn gray_btn" OnClientClick="return confirmOverrwrite('LoadSearch')" OnClick="btnLoadSearch_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, LoadSearchCriteria %>" />
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnNewSearch" runat="server" CssClass="btn gray_btn" OnClientClick="return confirmOverrwrite('NewSearch')" OnClick="btnNewSearch_Click">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"/>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, NewSearch %>" />
                        </asp:LinkButton>
                    </div>
                </div>
            </div>

            <div class="col-md-9 col-sm-9 col-xs-12 medpadding_lr">
                <%--Industry Type--%>
                <asp:Panel ID="pnlIndustryType" runat="server">
                    <div class="col-md-12 nopadding ind_typ gray_bg mar_top_15">
                        <div class="row nomargin">
                            <div class="col-md-3 text-nowrap">
                                <span id="popIndustryType" runat="server" class="msicon notranslate help" tabindex="0" data-bs-toggle="tooltip" data-bs-placement="right" data-bs-html="true">help</span>
                                <span class="fontbold"><strong class=""><%= Resources.Global.IndustryType %>:</strong></span>
                            </div>
                            <div class="col-md-9">
                                <asp:UpdatePanel ID="UpdatePanel3" runat="server">
                                    <ContentTemplate>
                                        <asp:RadioButtonList ID="rblIndustryType" runat="server" RepeatColumns="3" AutoPostBack="True" 
                                            Font-Size="Smaller" />
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="rblIndustryType" EventName="SelectedIndexChanged" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </div>
                        </div>
                    </div>
                </asp:Panel>
                
                <div class="row">
                    <div class="col-md-12"></div>
                </div>

                <%--Listing Country--%>
                <asp:Panel ID="trListingCountry" runat="server">
                    <div class="ind_typ bor_bot mar_top_13">
                        <div class="row">
                            <div class="col-md-12">
                                <p class="fontbold"><%= Resources.Global.ListingCountry %>&nbsp;</p>
                            </div>
                        </div>
                    </div>

                    <div class="row nomargin">
                        <div class="col-md-12 nopadding ind_typ gray_bg">
                            <div class="col-md-12 px-2">
                                <asp:CheckBoxList ID="cblCountryNA" runat="server" AutoPostBack="True" RepeatColumns="5" RepeatDirection="Horizontal" 
                                    CssClass="nowraptd_wraplabel norm_lbl" />
                            </div>
                            <div class="col-md-12 px-2">
                                <div id="cnView" class="btn gray_btn" onclick="javascript:ToggleCN(true);" runat="server">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server" />&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ViewAllCountries %>" />
                                </div>
                                <div id="cnHide" class="btn gray_btn" onclick="javascript:ToggleCN(false);" runat="server" style="display: none">
                                    <i class="fa fa-caret-right" aria-hidden="true" runat="server" />&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, HideMostCountries %>" />
                                </div>

                                <br />

                                <asp:Label CssClass="small" ID="countryRegions" runat="server">
                                    <span class="clr_blu small fontbold"><%=Resources.Global.Show %>:&nbsp;</span>
                                    <a href="javascript:showCountries('CA', true);" class="clr_blu"><%=Resources.Global.CentralAmerica %></a> <span class="clr_blu">|</span>
                                    <a href="javascript:showCountries('CR', true);" class="clr_blu"><%=Resources.Global.Caribbean %></a><span class="clr_blu">|</span>
                                    <a href="javascript:showCountries('SA', true);" class="clr_blu"><%=Resources.Global.SouthAmerica %></a> <span class="clr_blu">|</span>
                                    <a href="javascript:showCountries('EU', true);" class="clr_blu"><%=Resources.Global.Europe %></a> <span class="clr_blu">|</span>
                                    <a href="javascript:showCountries('CSAME', true);" class="clr_blu"><%=Resources.Global.CentralSouthAsiaMiddleEast %></a> <span class="clr_blu">|</span>
                                    <a href="javascript:showCountries('EAP', true);" class="clr_blu"><%=Resources.Global.EasternAsiaPacific%></a> <span class="clr_blu">|</span>
                                    <a href="javascript:showCountries('AF', true);" class="clr_blu"><%=Resources.Global.Africa %></a> <span class="clr_blu"></span>
                                    
                                    <br />

                                    <span class="clr_blu small fontbold"><%=Resources.Global.Hide %>:&nbsp;</span>
                                    <a href="javascript:showCountries('CA', false);" class="clr_blu"><%=Resources.Global.CentralAmerica %></a> <span class="clr_blu">|</span>
                                    <a href="javascript:showCountries('CR', false);" class="clr_blu"><%=Resources.Global.Caribbean %></a> <span class="clr_blu">|</span>
                                    <a href="javascript:showCountries('SA', false);" class="clr_blu"><%=Resources.Global.SouthAmerica %></a> <span class="clr_blu">|</span>
                                    <a href="javascript:showCountries('EU', false);" class="clr_blu"><%=Resources.Global.Europe %></a> <span class="clr_blu">|</span>
                                    <a href="javascript:showCountries('CSAME', false);" class="clr_blu"><%=Resources.Global.CentralSouthAsiaMiddleEast %></a> <span class="clr_blu">|</span>
                                    <a href="javascript:showCountries('EAP', false);" class="clr_blu"><%=Resources.Global.EasternAsiaPacific %></a> <span class="clr_blu">|</span>
                                    <a href="javascript:showCountries('AF', false);" class="clr_blu"><%=Resources.Global.Africa %></a> <span class="clr_blu"></span>
                                </asp:Label>

                                <asp:HiddenField ID="hidCA" runat="server" Value="false" />
                                <asp:HiddenField ID="hidCR" runat="server" Value="false" />
                                <asp:HiddenField ID="hidSA" runat="server" Value="false" />
                                <asp:HiddenField ID="hidEU" runat="server" Value="false" />
                                <asp:HiddenField ID="hidCSAME" runat="server" Value="false" />
                                <asp:HiddenField ID="hidEAP" runat="server" Value="false" />
                                <asp:HiddenField ID="hidAF" runat="server" Value="false" />

                                <div id="CountryCA" style="margin-top: 10px;">
                                    <input id="cbCountryCA_All" type="checkbox" onclick="javascript: checkCountries(this,'CA');" />
                                    <span style="font-weight: bold;" class="clr_blu">
                                        <asp:Literal ID="lblCA" runat="server" />
                                    </span>
                                    <asp:CheckBoxList ID="cblCountryCA" runat="server" AutoPostBack="True" RepeatColumns="3" 
                                        RepeatDirection="Horizontal" Width="100%" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel" />
                                </div>

                                <div id="CountryCR" style="margin-top: 10px;">
                                    <input id="cbCountryCR_All" type="checkbox" onclick="javascript: checkCountries(this, 'CR');" />
                                    <span style="font-weight: bold;" class="clr_blu">
                                        <asp:Literal ID="lblCR" runat="server" /></span>
                                    <asp:CheckBoxList ID="cblCountryCR" runat="server" AutoPostBack="True" RepeatColumns="3" 
                                        RepeatDirection="Horizontal" Width="100%" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel" />
                                </div>

                                <div id="CountrySA" style="margin-top: 10px;">
                                    <input id="cbCountrySA_All" type="checkbox" onclick="javascript: checkCountries(this, 'SA');" />
                                    <span style="font-weight: bold;" class="clr_blu">
                                        <asp:Literal ID="lblSA" runat="server" /></span>
                                    <asp:CheckBoxList ID="cblCountrySA" runat="server" AutoPostBack="True" RepeatColumns="3" 
                                        RepeatDirection="Horizontal" Width="100%" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel" />
                                </div>

                                <div id="CountryEU" style="margin-top: 10px;">
                                    <input id="cbCountryEU_All" type="checkbox" onclick="javascript: checkCountries(this, 'EU');" />
                                    <span style="font-weight: bold;" class="clr_blu">
                                        <asp:Literal ID="lblEU" runat="server" /></span>
                                    <asp:CheckBoxList ID="cblCountryEU" runat="server" AutoPostBack="True" RepeatColumns="3" 
                                        RepeatDirection="Horizontal" Width="100%" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel" />
                                </div>

                                <div id="CountryCSAME" style="margin-top: 10px;">
                                    <input id="cbCountryCSAME_All" type="checkbox" onclick="javascript: checkCountries(this, 'CSAME');" />
                                    <span style="font-weight: bold;" class="clr_blu">
                                        <asp:Literal ID="lblCSAME" runat="server" /></span>
                                    <asp:CheckBoxList ID="cblCountryCSAME" runat="server" AutoPostBack="True" RepeatColumns="3" 
                                        RepeatDirection="Horizontal" Width="100%" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel"/>
                                </div>

                                <div id="CountryEAP" style="margin-top: 10px;">
                                    <input id="cbCountryEAP_All" type="checkbox" onclick="javascript: checkCountries(this, 'EAP');" />
                                    <span style="font-weight: bold;" class="clr_blu">
                                        <asp:Literal ID="lblEAP" runat="server" /></span>
                                    <asp:CheckBoxList ID="cblCountryEAP" runat="server" AutoPostBack="True" RepeatColumns="3" 
                                        RepeatDirection="Horizontal" Width="100%" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel"/>
                                </div>

                                <div id="CountryAF" style="margin-top: 10px;">
                                    <input id="cbCountryAF_All" type="checkbox" onclick="javascript: checkCountries(this, 'AF');" />
                                    <span style="font-weight: bold;" class="clr_blu">
                                        <asp:Literal ID="lblAF" runat="server" /></span>
                                    <asp:CheckBoxList ID="cblCountryAF" runat="server" AutoPostBack="True" RepeatColumns="3" 
                                        RepeatDirection="Horizontal" Width="100%" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel"/>
                                </div>
                            </div>
                        </div>
                    </div>
                </asp:Panel>

                <%--Listing State/Province--%>
                <asp:Panel ID="trListingStateProvince" runat="server">
                    <div class="ind_typ bor_bot mar_top">
                        <div class="row">
                            <div class="col-md-5">
                                <p class="fontbold"><%= Resources.Global.ListingStateProvince %>&nbsp;</p>
                            </div>

                            <div class="col-md-7 text-right annotation label_top_5">
                                <%= Resources.Global.StateSearchText %>
                            </div>
                        </div>
                    </div>

                    <div class="row nomargin">
                        <div class="col-md-12 nopadding ind_typ gray_bg">
                            <div class="col-md-12 px-2">
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
                                                RepeatDirection="Vertical" Width="100%" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel" />
                                        </asp:Panel>

                                        <asp:Panel ID="pnlStatesFor_2" runat="server" Visible="false">
                                            <asp:Label ID="lblCountryName_2" runat="server" Style="font-weight: bold;" CssClass="clr_blu"></asp:Label><br />
                                            <asp:CheckBoxList ID="cblStatesFor_2" runat="server" Style="table-layout: fixed;" AutoPostBack="true" RepeatColumns="3"
                                                RepeatDirection="Vertical" Width="100%" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel">
                                            </asp:CheckBoxList>
                                        </asp:Panel>
                                        <asp:Panel ID="pnlStatesFor_3" runat="server" Visible="false">
                                            <asp:Label ID="lblCountryName_3" runat="server" Style="font-weight: bold;" CssClass="clr_blu"></asp:Label><br />
                                            <asp:CheckBoxList ID="cblStatesFor_3" runat="server" Style="table-layout: fixed;" AutoPostBack="true" RepeatColumns="3"
                                                RepeatDirection="Vertical" Width="100%" CssClass="checkboxlist-3col fontsize13 nowraptd_wraplabel" />
                                        </asp:Panel>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="cblCountryNA" EventName="SelectedIndexChanged" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </div>
                        </div>
                    </div>
                </asp:Panel>

                <%--Listing City/Country/market/postal/radius--%>
                <div class="col-md-12 nopadding ind_typ gray_bg mar_top">
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
                                <%= Resources.Global.TerminalMarket %>:
                            </div>
                            <div class="col-md-10">
                                <asp:Panel ID="pnlTMButtons" runat="server">
                                    <div id="tmView" class="btn gray_btn" onclick="javascript:ToggleTM(true);" runat="server">
                                        <i class="fa fa-caret-right" aria-hidden="true" runat="server" />&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ShowTerminalMarkets %>" />
                                    </div>

                                    <div id="tmHide" class="btn gray_btn" onclick="javascript:ToggleTM(false);" runat="server" style="display: none;">
                                        <i class="fa fa-caret-right" aria-hidden="true" runat="server" />&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, HideTerminalMarkets %>" />
                                    </div>
                                </asp:Panel>
                            </div>
                        </div>
                    </asp:Panel>

                    <asp:UpdatePanel ID="UpdatePanel4" runat="server">
                        <ContentTemplate>
                            <div class="row nomargin_lr">
                                <div class="col-md-12">
                                    <asp:CheckBoxList ID="cblTerminalMarket" runat="server" Font-Size="Smaller" AutoPostBack="True" RepeatColumns="2" 
                                        RepeatDirection="Horizontal" RepeatLayout="Table" CssClass="checkboxlist-2col fontsize13 nowraptd_wraplabel"/>
                                </div>
                            </div>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="cblCountryNA" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cblStatesFor_1" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cblStatesFor_2" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="cblStatesFor_3" EventName="SelectedIndexChanged" />
                        </Triggers>
                    </asp:UpdatePanel>

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
                                <asp:HyperLink ID="btnLookupPostalCode" CssClass="btn gray_btn" runat="server" Target="_blank" Font-Size="Smaller">
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
                        <div class="col-md-8 form-inline">
                            <asp:Label ID="lblMilesOf" runat="server" CssClass="bbos_blue" />
                            <br />
                            <asp:RadioButtonList ID="rblRadiusSearchType" runat="server" AutoPostBack="True" RepeatColumns="2" RepeatDirection="Horizontal" RepeatLayout="Flow" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <div class="row">
        <p>
            <% =GetSearchButtonMsg() %>
        </p>
    </div>

    <div id="pnlCityAutoComplete" style="z-index: 5000;"></div>
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        btnSubmitOnEnter = document.getElementById('<% =btnSearch.ClientID %>');
        ToggleTM(false);
        ToggleCN(false);
        function refreshCriteria() {
            <%=ClientScript.GetPostBackEventReference(UpdatePanel1, "")%>;
        }

        Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(checkForToggle);
    </script>
</asp:Content>
