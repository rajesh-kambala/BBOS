<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EMCW_CompanyListing.aspx.cs"
    Inherits="PRCo.BBOS.UI.Web.EMCW_CompanyListing" MasterPageFile="~/BBOS.Master"
    EnableEventValidation="false" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="bbos" TagName="EMCW_CompanyHeader" Src="~/UserControls/EMCW_CompanyHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyListing" Src="UserControls/CompanyListing.ascx" %>

<asp:Content ContentPlaceHolderID="contentHead" runat="server">
    <script type="text/javascript">
        function postStdValidation(form) {

            var errMsg = "";
            var textBoxes = document.getElementsByTagName("input");
            for (i = 0; i < textBoxes.length; i++) {
                if (textBoxes[i].id.indexOf("txtSMURL_") == 0) {
                    var code = textBoxes[i].id.substring(9, textBoxes[i].id.length);
                    errMsg += validateSocialMediaURL(code)
                }
            }

            if (errMsg.length > 0) {
                displayErrorMessage(errMsg);
                return false;
            }

            return true;
        }

        function validateSocialMediaURL(code) {

            var domain = document.getElementById("hdnSMDomain_" + code).value;
            var url = document.getElementById("txtSMURL_" + code).value;

            if (url.length == 0) {
                return "";
            }

            if (url.toLowerCase().indexOf("http://") == 0) {
                url = url.substring(7, url.length);
            } else if (url.toLowerCase().indexOf("https://") == 0) {
                url = url.substring(8, url.length);
            }


            var posSlash = url.indexOf("/");
            var posDomain = url.indexOf(domain);

            if ((posDomain == -1) ||
                (posDomain > posSlash)) {

                var label = document.getElementById("tdSM_" + code).innerText;
                return " - An invalid social media URL has been specified for the " + label + "\n";
            }

            return "";
        }

        function aceCommoditySelected(source, eventArgs) {
            if (eventArgs.get_value() != null) {

                var keys = eventArgs.get_value().split("|");

                var controlKey = keys[0] + "|" + keys[1] + "|" + keys[2];
                var abbreviation = keys[3];

                var publish = "N";
                if ($("#cbPublish").is(':checked'))
                    publish = "Y";

                var commodity = {
                    commodityid: keys[0],
                    attributeid: keys[1],
                    growingmethodid: keys[2],
                    abbreviation: keys[3],
                    controlKey: controlKey,
                    description: eventArgs.get_text(),
                    publish: publish
                };

                if ($("#contentMain_txtCommodities").val().length == 0)
                    $("#contentMain_txtCommodities").val(commodity.description);
                else
                    $("#contentMain_txtCommodities").val($("#contentMain_txtCommodities").val() + ", " + commodity.description);

                setTimeout(function () { $("#contentMain_txtCommodity").select().focus(); }, 100);
            }
        }
    </script>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="contentMain" runat="server">
    <div class="row">
        <div class="col-md-4">
            <%--Company Header--%>
            <bbos:EMCW_CompanyHeader ID="ucCompanyDetailsHeader" runat="server" />

            <%--Listing Report Button--%>
            <div class="row nomargin_lr mar_top_5">
                <div class="col-md-12">
                    <asp:LinkButton ID="btnListingReport" runat="server" CssClass="btn gray_btn" OnClick="btnListingReport_Click" OnClientClick="bDirty=false">
                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, ListingReport %>" />
                    </asp:LinkButton>
                </div>
            </div>

            <%--Listing Panel--%>
            <bbos:CompanyListing ID="ucCompanyListing" runat="server" Visible="true" />

            <asp:HiddenField ID="hidCompanyID" runat="server" />
            <asp:HiddenField ID="hidIncludeBranches" Value="false" runat="server" />
        </div>
        <div class="col-md-8 nomargin nopadding">
            <div class="row">
                <div class="col-md-12 clr_blu">
                    <%= Resources.Global.EMCWCompanyListingHeaderText %>
                </div>
            </div>

            <asp:Panel ID="pnlEnterprise" runat="server" Visible="false">
                <div class="row">
                    <div class="col-md-12 form-inline label_top">
                        <span class="clr_blu"><% =Resources.Global.Company %>:</span>
                        <asp:DropDownList ID="ddlCompanies" tsiSkipOnChange="true" runat="server" CssClass="form-control"></asp:DropDownList>
                        &nbsp;
                        <asp:LinkButton ID="btnSelectCompany" runat="server" CssClass="btn gray_btn" OnClick="btnSelectOnClick" OnClientClick="return onCompanyChange();">
                            <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Select %>" />
                        </asp:LinkButton>
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlNotListed" runat="server" Visible="false">
                <div class="row nomargin">
                    <div class="col-md-12 clr_blu">
                        <%= Resources.Global.EditCompanyNotListedText %>
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlNoEdit" runat="server" Visible="false">
                <div class="row nomargin">
                    <div class="col-md-12 clr_blu">
                        <%= Resources.Global.NoEditRole%>
                    </div>
                </div>
            </asp:Panel>

            <div class="row">
                <div class="col-md-12">
                    <asp:LinkButton ID="btnEditPersonnelList" runat="server" CssClass="btn gray_btn" OnClick="btnEditPersonnelList_Click" >
                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, EditPersonnelList %>" />
                    </asp:LinkButton>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <%-- Requested Changes --%>
                    <div class="row panels_box">
                        <div class="col-md-12">
                            <div class="panel panel-primary">
                                <div class="panel-heading">
                                    <h4 class="blu_tab">
                                        <%= Resources.Global.RequestedChanges %>
                                    </h4>
                                </div>
                                <div class="panel-body nomargin pad10 gray_bg">
                                    <div class="row nomargin_lr">
                                       

                                        <div class="row mar_top_5">
                                            <div class="col-md-12">
                                                <span class="bold">
                                                    <% =Resources.Global.CompanyAddresses2 %>:
                                                </span>
                                                <br />
                                                <asp:TextBox ID="txtAddresses" runat="server" Rows="5" TextMode="MultiLine" CssClass="form-control"/>
                                            </div>
                                        </div>

                                        <div class="row mar_top_5">
                                            <div class="col-md-12">
                                                <span class="bold">
                                                    <% =Resources.Global.CompanyPhoneNumbers2 %>:
                                                </span>
                                                <br />
                                                <asp:TextBox ID="txtPhoneNumbers" runat="server" Rows="5" TextMode="MultiLine" CssClass="form-control" />
                                            </div>
                                        </div>

                                        <div class="row mar_top_5">
                                            <div class="col-md-12">
                                                <span class="bold">
                                                    <% =Resources.Global.CompanyEmailWebSite2 %>:
                                                </span>
                                                <br />
                                                <asp:TextBox ID="txtEmailWeb" runat="server" Rows="5" TextMode="MultiLine" CssClass="form-control" />
                                            </div>
                                        </div>

                                        <asp:Panel ID="pnlProduce" runat="server">
                                            <div class="row">
                                                <span class="bold">
                                                <div class="col-md-12">
                                                    <div class="form-group">
                                                        <div class="col-sm-2">
                                                            <% =Resources.Global.Commodities %>:
                                                        </div>

                                                        <div class="col-sm-10 mar_bot_10 ">
                                                            <asp:TextBox ID="txtCommodity" Width="300" runat="server" onkeydown="return (event.keyCode!=13);" CssClass="form-control" placeholder='<%$ Resources:Global, SearchForCommodity %>' AutoComplete="off" />
                                                            <div id="pnlCommodityFindAutoComplete" style="z-index: 5000; width: 350px!important"></div>

                                                            <cc1:AutoCompleteExtender ID="aceCommodity" runat="server"
                                                                TargetControlID="txtCommodity"
                                                                BehaviorID="aceCommodity"
                                                                ServiceMethod="GetCommodityList"
                                                                ServicePath="AJAXHelper.asmx"
                                                                CompletionInterval="100"
                                                                MinimumPrefixLength="2"
                                                                CompletionSetCount="20"
                                                                CompletionListCssClass="AutoCompleteFlyout"
                                                                CompletionListItemCssClass="AutoCompleteFlyoutItem"
                                                                CompletionListHighlightedItemCssClass="AutoCompleteFlyoutItem"
                                                                CompletionListElementID="pnlCommodityFindAutoComplete"
                                                                OnClientItemSelected="aceCommoditySelected"
                                                                DelimiterCharacters="|"
                                                                EnableCaching="True"
                                                                ContextKey="N|N"
                                                                FirstRowSelected="false">
                                                            </cc1:AutoCompleteExtender>
                                                        </div>
                                                    </div>

                                                    <br />
                                                    <asp:TextBox ID="txtCommodities" runat="server" Rows="5" TextMode="MultiLine" CssClass="form-control" />
                                                </div>
                                                </span>
                                            </div>
                                        </asp:Panel>

                                        <asp:Panel ID="pnlLumber" runat="server">
                                            <div class="row mar_top_5">
                                                <div class="col-md-12">
                                                    <span class="bold">
                                                        <% =Resources.Global.Specie %>:
                                                    </span>
                                                    <br />
                                                    <asp:TextBox ID="txtSpecie" runat="server" Rows="5" TextMode="MultiLine" CssClass="form-control" />
                                                </div>
                                            </div>

                                            <div class="row mar_top_5">
                                                <div class="col-md-12">
                                                    <span class="bold">
                                                        <% =Resources.Global.Product %>:
                                                    </span>
                                                    <br />
                                                    <asp:TextBox ID="txtProductProvided" runat="server" Rows="5" TextMode="MultiLine" CssClass="form-control" />
                                                </div>
                                            </div>

                                            <div class="row mar_top_5">
                                                <div class="col-md-12">
                                                    <span class="bold">
                                                        <% =Resources.Global.Services %>:
                                                    </span>
                                                    <br />
                                                    <asp:TextBox ID="txtServicesProvided" runat="server" Rows="5" TextMode="MultiLine" CssClass="form-control" />
                                                </div>
                                            </div>
                                        </asp:Panel>

                                        <div class="row mar_top_5">
                                            <div class="col-md-12">
                                                <span class="bold">
                                                    <% =Resources.Global.Classifications %>: 
                                                </span>
                                                <br />
                                                <asp:TextBox ID="txtClassifications" runat="server" Rows="5" TextMode="MultiLine" CssClass="form-control" />
                                            </div>
                                        </div>

                                        <div class="row mar_top_5">
                                            <span class="bold">
                                                <div class="col-md-12">
                                                    <div class="form-group">
                                                        <div class="col-md-12">
                                                            <asp:Literal ID="litVolumeText" runat="server"></asp:Literal>
                                                            
                                                        </div>
                                                        <div class="col-md-12 mar_bot_10 nopadding_lr">
                                                            <asp:DropDownList ID="ddlVolume" runat="server" CssClass="form-control" />
                                                        </div>
                                                    </div>
                                                </div>
                                            </span>
                                        </div>
                                        
                                        <div class="row mar_top_5 mar_bot_5">
                                            <div class="col-md-12">
                                                <span class="bold">
                                                    <% =Resources.Global.Brands %>:
                                                </span>
                                                <br />
                                                <asp:TextBox ID="txtBrands" runat="server" Rows="5" TextMode="MultiLine" CssClass="form-control" />
                                            </div>
                                        </div>

                                        <asp:Repeater ID="repSocialMediaDomains" runat="server">
                                            <ItemTemplate>
                                                <input type="hidden" id="hdnSMDomain_<%# Eval("Code") %>" value="<%# Eval("Meaning") %>" />
                                            </ItemTemplate>
                                        </asp:Repeater>

                                        <asp:Panel ID="pnlSocialMedia" runat="server">
                                            <asp:Repeater ID="repSocialMedia" runat="server" OnItemDataBound="repSocialMedia_ItemDataBound">
                                                <ItemTemplate>
                                                    <div class="row mar_bot">
                                                        <div class="col-md-12">
                                                            <span class="bold" id="tdSM_<%# Eval("capt_Code") %>"><%# Eval("capt_US") %>:&nbsp;
                                                                <a id="popWhatIsSM" runat="server" class="clr_blc cursor_pointer" data-bs-html="true" style="color: #000;" data-bs-toggle="modal" data-bs-target="#pnlSM">
                                                                    <asp:Image runat="server" ImageUrl="images/info_sm.png" ToolTip="<%$ Resources:Global, WhatIsThis %>" />
                                                                </a>
                                                            </span>
                                                            <br />

                                                            <input type="text" name="txtSMURL_<%# Eval("capt_Code") %>" id="txtSMURL_<%# Eval("capt_Code") %>" value="<%# Eval("prsm_URL") %>" maxlength="500" onchange="validateSocialMediaURL('<%# Eval("capt_Code") %>');" class="form-control" />
                                                            <input type="hidden" name="hdnSMID_<%# Eval("capt_Code") %>" id="hdnSMID_<%# Eval("capt_Code") %>" value="<%# Eval("prsm_SocialMediaID") %>" />
                                                        </div>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </asp:Panel>

                                        <div id="pnlSM" class="modal fade" role="dialog">
                                            <div class="modal-dialog">
                                                <!-- Modal content-->
                                                <div class="modal-content">
                                                    <div class="modal-header">
                                                        <button type="button" class="close" data-bs-dismiss="modal">&times;</button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <span class="sml_font">
                                                            <%= Resources.Global.SocialMediaHelp %>
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="row mar_top_5 mar_bot_5">
                                            <div class="col-md-12">
                                                <span class="bold">
                                                    <% =Resources.Global.OtherRequests %>:
                                                    <button type="button" id="btnDLIdeas" class="btn gray_btn smallpadding_tb" data-bs-toggle="modal" data-bs-target="#pnlDLIdeas" runat="server">
                                                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, IdeasForListingEnhancements %>" />
                                                    </button>
                                                </span>
                                                <br />
                                                <asp:TextBox ID="txtOther" runat="server" Rows="5" TextMode="MultiLine" CssClass="form-control mar_top_5" />
                                            </div>
                                        </div>

                                        <div class="row mar_top_10">
                                            <div class="col-md-3">
                                                <span class="bold">
                                                    <% =Resources.Global.CertificationFile %>:
                                                </span>
                                            </div>
                                            <div class="col-md-9 label_top">
                                                <asp:FileUpload ID="fileCertFile" runat="server" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row mar_top">
                <div class="col-md-9">
                    <asp:LinkButton ID="btnSubmit" runat="server" CssClass="btn gray_btn" OnClick="btnSubmit_Click" OnClientClick="bDirty=false">
                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Submit %>" />
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn gray_btn" OnClick="btnCancel_Click" OnClientClick="bDirty=false">
                        <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Cancel %>" />
                    </asp:LinkButton>
                </div>
            </div>
        </div>
    </div>

    <div class="text-left">
        <asp:Panel ID="pnlListingReport" Style="display: none" CssClass="Popup" Width="300" runat="server">
            <h4 class="blu_tab"><% =Resources.Global.PleaseConfirm %></h4>
            <div class="row mar_top">
                <div class="col-md-12">
                    <asp:Literal ID="litBranchMsg" runat="server"></asp:Literal>
                </div>
            </div>

            <div class="row mar_top">
                <div class="col-md-12">
                    <asp:LinkButton ID="btnYes" runat="server" CssClass="btn gray_btn" Width="75px" OnClientClick="bDirty=false">
		                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, Yes %>" />
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnNo" runat="server" CssClass="btn gray_btn" Width="75px" OnClientClick="bDirty=false">
		                <i class="fa fa-caret-right" aria-hidden="true" runat="server"></i>&nbsp;<asp:Literal runat="server" Text="<%$Resources:Global, No %>" />
                    </asp:LinkButton>
                </div>
            </div>
        </asp:Panel>

        <div id="pnlDLIdeas" class="modal fade" role="dialog">
            <div class="modal-dialog">
                <!-- Modal content-->
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-bs-dismiss="modal">&times;</button>
                    </div>
                    <div class="modal-body">
                        <span class="sml_font">
                            <asp:Literal ID="litDLIdeasHTML" runat="server" />
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="contentScript" ContentPlaceHolderID="ScriptSection" runat="server">
    <script type="text/javascript">
        // Declare our Dirty flag
        var bDirty = false;

        // This event will fire when any
        // control on the form is changed.
        function onDataChange() {
            bDirty = true;
        }

        // This function fires prior to the unloading
        // of the page.  It checks the Dirty flag to
        // determine if we should warn the user.
        function onCompanyChange() {
            if (bDirty == true) {
                return confirm("The Listing changes have not been saved.  If you continue, the changes will be lost.  Click 'OK' to switch to the selected company.  Click 'Cancel' to stay on this page.");
            }
        }

        // Iterate through all of the elements on
        // the form.  Set the element's onChange
        // event handler to the global handler to
        // set the dirty flag.
        function onFormLoad() {

            var oForm = document.forms[0];
            for (i = 0; i < oForm.elements.length; i++) {
                var oElement = oForm.elements[i];

                if (oElement.getAttribute('tsiSkipOnChange')) {
                    //
                } else {
                    oForm.elements[i].onchange = onDataChange;
                }
            }
        }

        // Set the appropriate event handlers.
        window.onload = onFormLoad;
    </script>
</asp:Content>
