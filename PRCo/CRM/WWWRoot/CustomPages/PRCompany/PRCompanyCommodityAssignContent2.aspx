<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeBehind="PRCompanyCommodityAssignContent2.aspx.cs" Inherits="PRCo.BBS.CRM.PRCompanyCommodityAssignContent2" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <link rel="shortcut icon" href="/CRM/Themes/img/ergonomic/Icons/favicon.ico?83568" type="image/x-icon" />
    <link rel="stylesheet" href="/CRM/Themes/ergonomic.css?83568" />
    <link rel="stylesheet" href="/CRM/Themes/Kendo/kendo.common.min.css" />
    <link rel="stylesheet" href="/CRM/Themes/Kendo/kendo.default.min.css" />
    <link rel="stylesheet" href="/CRM/Themes/Calendar/ergonomic/stylesheets/sagecalendar.css" />
    <link rel="stylesheet" href="/CRM/Themes/Calendar/ergonomic/stylesheets/tasklist.css" />

    <link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css" />

    <script src="https://code.jquery.com/jquery-1.12.4.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
    <script type="text/javascript">
        var btnSaveClick = false;

        function onSave() {
            if (btnSaveClick == true) {
                return;
            }
            btnSaveClick = true;

            refreshCommodities();
            return true;
        }

        $(window).on('load', function () {
            refreshCounts();
        });

        var commodities = [];
        $(function () {
            $("#tblCommodities").sortable({
                update: function (event, ui) {
                    refreshCommodities();
                }
            });

            $("#tblCommodities").disableSelection();
        });

        function refreshCommodities() {
            var work = [];
            var i = 0;

            $('#tblCommodities > tr').each(function () {
                $this = $(this);
                controlKey = $this.find("input.key").val();
                i++;

                for (var j = 0; j < commodities.length; j++) {
                    if (commodities[j].controlKey == controlKey) {
                        var commodity = commodities[j];
                        commodity.sequence = i;
                        work[work.length] = commodity;
                    }
                }
            })

            commodities = work;
            work = null;
            refreshTable();
            buildNewListing();
        }

        function selectCommodity(source, eventArgs) {
            if (eventArgs.get_value() != null) {

                var keys = eventArgs.get_value().split("|");

                var controlKey = keys[0] + "|" + keys[1] + "|" + keys[2];
                var abbreviation = keys[3];
                var sequence = commodities.length + 1;

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
                    publish: publish,
                    sequence: sequence
                };

                if (commodityExists(commodity.controlKey)) {
                    alert('Commodity "' + commodity.description + '" already exists.');
                }
                else {

                    commodities[commodities.length] = commodity;
                    addToTable(commodity);
                    $("#txtCommodity").val("");
                    buildNewListing();
                }
            }
        }

        function refreshTable() {
            $("#tblCommodities").empty();
            for (var j = 0; j < commodities.length; j++) {
                addToTable(commodities[j]);
            }
        }

        function addToTable(commodity) {
            var checked = "";
            if (commodity.publish == "Y")
                checked = "checked";

            var contents = "<tr>td class=\"commodBorder commodHandle\"></td>";
            contents += "<td class=\"commodBorder commodHandle\"></td><td class=\"commodBorder\">" + commodity.description + "</td>";
            contents += "<td class=\"commodBorder\" align=center><input type=checkbox " + checked + " id=\"cb" + commodity.sequence + "\" controlKey=\"" + commodity.controlKey + "\" onchange=\"togglePublish('" + commodity.controlKey + "');\"  ></td>";
            contents += "<td class=\"commodBorder\"><input type=\"hidden\" class=\"key\" id=\"hid" + commodity.sequence + "\" value=\"" + commodity.controlKey + "\"></td>";
            contents += "<td class=\"commodBorder\"><a href=\"javascript:removeCommodity('" + commodity.controlKey + "');\"><img src=\"/CRM/Themes/Img/Ergonomic/Buttons/delete.gif\" alt=\"Remove Commodity\" height=16 width=16></a></td>";
            contents += "</tr> ";

            $("#tblCommodities").append(contents);
            refreshHidden();
            refreshCounts();
        }

        function refreshHidden() {
            $("#hidCommodities").val(JSON.stringify(commodities));
        }

        function refreshCounts() {
            var threshold = 16;

            var clb = $("#currentListingBlock").html();
            var nlb = $("#newListingBlock").html();
            if (clb.split("<br>").length >= threshold)
                $("#CurrentBookLimitExceeded").show();
            else
                $("#CurrentBookLimitExceeded").hide();

            if (nlb.split("<br>").length >= threshold)
                $("#NewBookLimitExceeded").show();
            else
                $("#NewBookLimitExceeded").hide();

            if (clb == "")
                $("#currentCount").text("0");
            else
                $("#currentCount").text(clb.split("<br>").length);

            if (nlb == "")
                $("#newCount").text("");
            else
                $("#newCount").text(nlb.split("<br>").length);
        }

        function commodityExists(controlKey) {
            for (var j = 0; j < commodities.length; j++) {
                if (commodities[j].controlKey == controlKey) {
                    return true;
                }
            }

            return false;
        }

        function removeCommodity(controlKey) {

            if (!confirm("Are you sure you want to remove this commodity?"))
                return;

            var work = [];
            var i = 0;

            for (var j = 0; j < commodities.length; j++) {
                if (commodities[j].controlKey == controlKey)
                    continue;

                i++;
                var commodity = commodities[j];
                commodity.sequence = i;
                work[work.length] = commodity;
            }

            commodities = work;
            work = null;
            refreshTable();
            buildNewListing();
        }

        function setContextKey() {

            var contextKey = "|";
            if ($("#cbIncludeAttributes").is(':checked'))
                contextKey = "Y|";

            if ($("#cbIndluceGrowingMethods").is(':checked'))
                contextKey = contextKey + "Y";

            $find('aceCommodity').set_contextKey(contextKey);
        }

        function togglePublish(controlKey) {
            var cbPublish = $("input[controlKey='" + controlKey + "']");

            var publish = "N";
            if (cbPublish.is(':checked'))
                publish = "Y";

            for (var j = 0; j < commodities.length; j++) {
                if (commodities[j].controlKey == controlKey) {
                    commodities[j].publish = publish;
                    break;
                }
            }

            buildNewListing();
        }

        function buildCurrentListing() {
            return GetCurrentListing($("#hidCompanyID").val());
        }

        function GetCurrentListing(companyID) {
            xmlHttp = new XMLHttpRequest();
            xmlHttp.onreadystatechange = SetCurrentListing;
            xmlHttp.open("GET", "/CRM/CustomPages/ajaxhelper.asmx/GetCurrentListing?companyID=" + companyID, true);
            xmlHttp.send(null);
        }

        function SetCurrentListing() {
            if (xmlHttp.readyState == 4) {
                if (xmlHttp.responseXML != null) {
                    var result = $(xmlHttp.responseText)[2].innerText;
                    $("#currentListingBlock").html(result);
                    refreshCounts();
                }
            }
        } 

        function buildNewListing() {
            return GetNewListing($("#hidCompanyID").val());
        }

        function GetNewListing(companyID) {

            var ccArray = $('input:checkbox:checked').map(function () {
                return $(this).attr('controlkey');
            }).get().join(",");

            xmlHttp = new XMLHttpRequest();
            xmlHttp.onreadystatechange = SetNewListing;
            xmlHttp.open("GET", "/CRM/CustomPages/ajaxhelper.asmx/GetNewListing?companyID=" + companyID + "&ccArray=" + ccArray, true);
            xmlHttp.send(null);
        }

        function SetNewListing() {
            if (xmlHttp.readyState == 4) {
                if (xmlHttp.responseXML != null) {
                    var result = $(xmlHttp.responseText)[2].innerText;
                    $("#newListingBlock").html(result);
                    refreshHidden();
                    refreshCounts();
                }
            }
        } 

        function redirect(redirectUrl) {
            window.top.location.href = redirectUrl;
        }
    </script>

    <style>
        table.commodBorder {
            border: 1px solid gray;
        }

        th.commodBorder {
            padding: 2px 2px 2px 2px
        }

        td.commodBorder {
            border-top: 1px solid gray;
            border-bottom: 1px solid gray;
            padding: 2px 2px 2px 2px
        }

        .commodHandle {
            width: 10px !important;
            background-color: lightgray;
            border-right: 1px solid gray;
        }

        /* Auto Complete Flyout */
        .AutoCompleteFlyout {
            cursor: pointer;
            height: 500px;
            padding: 10px 0 10px 0;
            border: solid 0px gray;
            overflow: auto;
            background-color: #E0E0E0;
            padding: 5px 0px 5px 0px;
            opacity: 0.92;
        }

        .AutoCompleteFlyoutItem {
            font-family: 'Work Sans', sans-serif;
            font-size: 0.9em;
            border-bottom: solid 1px #fff;
            padding: 10px 5px 10px 5px;
            text-align: left;
        }

        .AutoCompleteFlyoutShadeItem {
            font-family: 'Work Sans', sans-serif;
            font-size: 0.9em;
            border-bottom: solid 1px #fff;
            padding: 10px 5px 10px 5px;
            text-align: left;
        }

        .AutoCompleteFlyoutHilightedItem {
            color: white;
            font-family: 'Work Sans', sans-serif;
            font-size: 0.9em;
            font-weight: bold;
            background-color: gray;
            border-bottom: solid 1px #fff;
            padding: 10px 5px 10px 5px;
            text-align: left;
        }
    </style>

</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" EnablePartialRendering="true" EnableScriptGlobalization="true" EnablePageMethods="true" runat="server" />
        <asp:HiddenField ID="hidSID" runat="server" />
        <asp:HiddenField ID="hidCompanyID" runat="server" />
        <asp:HiddenField ID="hidUserID" runat="server" />
        <asp:HiddenField ID="hidCommodities" runat="server" />

        <div>
            <table width="100%">
                <tr>
                    <td>
                        <asp:Label ID="lblMsg" runat="server" Font-Bold="True"></asp:Label>
                    </td>
                </tr>
            </table>

            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tbody>
                    <tr>
                        <td style="width: 15px;"></td>
                        <td width="95%">
                            <table width="100%" cellpadding="5">
                                <tbody>
                                    <tr></tr>
                                    <tr>
                                        <td valign="TOP">
                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tbody>
                                                    <tr>
                                                        <td style="width: 15px;"></td>
                                                        <td width="95%">
                                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                                <tbody>
                                                                    <tr class="GridHeader">
                                                                        <td class="TABLEHEADBLANK" colspan="2">
                                                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                                                <tbody>
                                                                                    <tr>
                                                                                        <td class="PanelCorners" valign="BOTTOM">
                                                                                            <img title="" align="TOP" src="/CRM/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" border="0" hspace="0"></td>
                                                                                        <td width="10%" class="PANEREPEAT" nowrap="TRUE" valign="BOTTOM">Assign Commodities</td>
                                                                                        <td class="PanelCorners" valign="BOTTOM">
                                                                                            <img title="" align="TOP" src="/CRM/Themes/img/ergonomic/backgrounds/panerightcorner.gif" border="0" hspace="0"></td>
                                                                                        <td class="TABLETOPBORDER" valign="BOTTOM">&nbsp;</td>
                                                                                        <td class="TABLETOPBORDER" valign="BOTTOM">&nbsp;</td>
                                                                                        <td width="90%" class="TABLETOPBORDER" valign="MIDDLE">&nbsp;</td>
                                                                                    </tr>
                                                                                </tbody>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                    <tr class="CONTENT">
                                                                        <td width="1" class="TABLEBORDERLEFT">
                                                                            <img title="" align="TOP" src="/CRM/Themes/img/ergonomic/backgrounds/tabletopborder.gif" border="0" hspace="0"></td>
                                                                        <td width="100%" height="100%" class="">

                                                                            <!-- CONTENT -->
                                                                            <table>
                                                                                <tr>
                                                                                    <td style="width: 325px; vertical-align: top;">
                                                                                        <strong>Find Commodity:</strong><br />

                                                                                        <asp:CheckBox ID="cbPublish" Text="Publish in Book" Checked="true" runat="server" /><br />
                                                                                        <asp:CheckBox ID="cbIncludeAttributes" Text="Include Attributes in Find" Checked="false" onchange="setContextKey();" runat="server" /><br />
                                                                                        <asp:CheckBox ID="cbIndluceGrowingMethods" Text="Include Growing Methods in Find" Checked="false" onchange="setContextKey();" runat="server" /><br />

                                                                                        <asp:TextBox ID="txtCommodity" Width="300" Style="padding: 2px 2px 2px 2px; height: 20px;" runat="server" onkeydown = "return (event.keyCode!=13);" />

                                                                                        <div id="pnlCommodityFindAutoComplete" style="z-index: 5000; width: 350px!important"></div>

                                                                                        <cc1:autocompleteextender id="AutoCompleteExtender1" runat="server"
                                                                                            targetcontrolid="txtCommodity"
                                                                                            behaviorid="aceCommodity"
                                                                                            servicemethod="GetCommodityCompletionList"
                                                                                            completioninterval="100"
                                                                                            minimumprefixlength="2"
                                                                                            completionsetcount="100"
                                                                                            onclientitemselected="selectCommodity"
                                                                                            completionlistcssclass="AutoCompleteFlyout"
                                                                                            completionlistitemcssclass="AutoCompleteFlyoutItem"
                                                                                            completionlisthighlighteditemcssclass="AutoCompleteFlyoutHilightedItem"
                                                                                            completionlistelementid="pnlCommodityFindAutoComplete"
                                                                                            enablecaching="false"
                                                                                            contextkey="N|N"
                                                                                            firstrowselected="false">
                                                                                        </cc1:autocompleteextender>
                                                                                    </td>
                                                                                    <td style="width: 400px;">
                                                                                        <table style="width: 100%">
                                                                                            <tr>
                                                                                                <td valign="top">
                                                                                                    <table class="commodBorder" cellpadding="0" cellspacing="0" width="100%">
                                                                                                        <tr>
                                                                                                            <th class="commodBorder"></th>
                                                                                                            <th>Commodity</th>
                                                                                                            <th class="commodBorder" width="100">Book Publish</th>
                                                                                                            <th></th>
                                                                                                        </tr>
                                                                                                        <tbody id="tblCommodities">
                                                                                                    </table>
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>
                                                                                    </td>

                                                                                    <td style="width: 325px; vertical-align: top;">

                                                                                        <strong>Current Saved Values</strong>
                                                                                        <table class="MessageContent2" id="CurrentBookLimitExceeded" style="display:none;">
                                                                                            <tr>
                                                                                                <td>
                                                                                                    Commodity line exceeds book line count limit.
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>
                                                                                        <table>
                                                                                            <tr>
                                                                                                <td><span class="VIEWBOXCAPTION">Classification / Volume / Commodity Line Count:</span><br />
                                                                                                    <span class="VIEWBOX" id="currentCount">&nbsp;</span>
                                                                                                </td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td><span class="VIEWBOXCAPTION">Current Listing:</span><br />
                                                                                                    <span class="VIEWBOX" style="font-family: 'Courier New'" id="currentListingBlock"></span>
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>

                                                                                        <p>&nbsp;</p>

                                                                                        <strong>Current Unsaved Working Values</strong>
                                                                                        <table class="MessageContent2" id="NewBookLimitExceeded" style="display:none;">
                                                                                            <tr>
                                                                                                <td>
                                                                                                    Commodity line exceeds book line count limit.
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>

                                                                                        <table>
                                                                                            <tr>
                                                                                                <td><span class="VIEWBOXCAPTION">Classification / Volume / Commodity Line Count:</span><br />
                                                                                                    <span class="VIEWBOX" id="newCount">&nbsp;</span>
                                                                                                </td>
                                                                                            </tr>

                                                                                            <tr>
                                                                                                <td><span class="VIEWBOXCAPTION">New Listing:</span><br />
                                                                                                    <span class="VIEWBOX" style="font-family: 'Courier New'" id="newListingBlock"></span>
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>

                                                                                    </td>

                                                                                </tr>
                                                                            </table>

                                                                        </td>
                                                                        <td width="1" class="TABLEBORDERRIGHT">
                                                                            <img title="" align="TOP" src="/CRM/Themes/img/ergonomic/backgrounds/tabletopborder.gif" border="0" hspace="0"></td>
                                                                    </tr>
                                                                    <tr height="1">
                                                                        <td width="1" class="TABLEBORDERBOTTOM" colspan="3"></td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                        <td>&nbsp;</td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>

                        </td>
                        <td style="min-width: 150px;">&nbsp;</td>
                        <td width="5%" id="RightButtonPanel" valign="TOP" style="right: 130px; padding-top: 27.5px;">

                            <!-- BUTTONS -->
                            <table class="Button">
                                <tbody>
                                    <tr>
                                        <td class="Button">
                                            <table border="0" cellspacing="0" cellpadding="0">
                                                <tbody>
                                                    <tr>
                                                        <td>
                                                            <a class="er_buttonItemImg" id="Button_Cancel_IMG" href="#">
                                                                <img title="" align="MIDDLE" src="/CRM/Themes/img/ergonomic/Buttons/new.gif" border="0">
                                                            </a>
                                                        </td>
                                                        <td>&nbsp;</td>
                                                        <td>
                                                            <asp:LinkButton ID="Button_Cancel" runat="server" PostBackUrl="#" Text="Cancel" CssClass="er_buttonItem" OnClick="btnCancelOnClick" />
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="Button">
                                            <table border="0" cellspacing="0" cellpadding="0">
                                                <tbody>
                                                    <tr>
                                                        <td>
                                                            <a class="er_buttonItemImg" id="Button_Save_IMG" href="#">
                                                            <img title="" align="MIDDLE" src="/CRM/Themes/img/ergonomic/Buttons/save.gif" border="0"></a></td>
                                                        <td>&nbsp;</td>
                                                        <td>
                                                            <asp:LinkButton ID="Button_Save" runat="server" Text="Save" PostBackUrl="#" CssClass="er_buttonItem" OnClick="btnSaveOnClick" OnClientClick="return onSave();" />
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </td>
                    </tr>
                </tbody>
            </table>

            <input type="hidden" id="hidClassVolBlock" value="" />
            <script>
                //alert(commodities.length + "\n" + commodities[0].description + "\n" + commodities[commodities.length-1].description);
            </script>
        </div>
    </form>
</body>
</html>
