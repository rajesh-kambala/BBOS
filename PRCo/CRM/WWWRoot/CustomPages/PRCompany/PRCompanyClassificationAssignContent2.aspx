<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeBehind="PRCompanyClassificationAssignContent2.aspx.cs" Inherits="PRCo.BBS.CRM.PRCompanyClassificationAssignContent2" %>
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

            refreshClassifications();
            return true;
        }

        $(window).on('load', function () {
        });

        var classifications = [];
        $(function () {
            $("#tblClassifications").sortable({
                update: function (event, ui) {
                    refreshClassifications();
                }
            });

            $("#tblClassifications").disableSelection();
        });

        function refreshClassifications() {
            var work = [];
            var i = 0;

            $('#tblClassifications > tr').each(function () {
                $this = $(this);
                controlKey = $this.find("input.key").val();
                i++;

                for (var j = 0; j < classifications.length; j++) {
                    if (classifications[j].controlKey == controlKey) {
                        var classification = classifications[j];
                        classification.sequence = i;
                        work[work.length] = classification;
                    }
                }
            })

            classifications = work;
            work = null;
            refreshTable();
        }

        function selectClassification(source, eventArgs) {
            if (eventArgs.get_value() != null) {

                var keys = eventArgs.get_value().split("|");

                var controlKey = keys[0] + "|" + keys[1] + "|" + keys[2];
                var abbreviation = keys[3];
                var sequence = classifications.length + 1;

                var publish = "N";
                if ($("#cbPublish").is(':checked'))
                    publish = "Y";

                var classification = {
                    classificationid: keys[0],
                    abbreviation: keys[3],
                    controlKey: controlKey,
                    description: eventArgs.get_text(),
                    publish: publish,
                    sequence: sequence
                };

                if (classificationExists(classification.controlKey)) {
                    alert('Classification "' + classification.description + '" already exists.');
                }
                else {

                    classifications[classifications.length] = classification;
                    addToTable(classification);
                    $("#txtClassification").val("");
                }
            }
        }

        function refreshTable() {
            $("#tblClassifications").empty();
            for (var j = 0; j < classifications.length; j++) {
                addToTable(classifications[j]);
            }
        }

        function addToTable(classification) {
            var contents = "<tr>td class=\"commodBorder commodHandle\"></td>";
            contents += "<td class=\"commodBorder commodHandle\"></td><td class=\"commodBorder\">" + classification.name + "</td>";
            contents += "<td class=\"commodBorder\"><input type=\"hidden\" class=\"key\" id=\"hid" + classification.sequence + "\" value=\"" + classification.controlKey + "\"></td>";
            contents += "<td class=\"commodBorder\"><a href=\"javascript:removeClassification('" + classification.controlKey + "');\"><img src=\"/CRM/Themes/Img/Ergonomic/Buttons/delete.gif\" alt=\"Remove Classification\" height=16 width=16></a></td>";
            contents += "</tr> ";

            $("#tblClassifications").append(contents);
            refreshHidden();
        }

        function refreshHidden() {
            $("#hidClassifications").val(JSON.stringify(classifications));
        }

        function classificationExists(controlKey) {
            for (var j = 0; j < classifications.length; j++) {
                if (classifications[j].controlKey == controlKey) {
                    return true;
                }
            }

            return false;
        }

        function removeClassification(controlKey) {

            if (!confirm("Are you sure you want to remove this classification?"))
                return;

            var work = [];
            var i = 0;

            for (var j = 0; j < classifications.length; j++) {
                if (classifications[j].controlKey == controlKey)
                    continue;

                i++;
                var classification = classifications[j];
                classification.sequence = i;
                work[work.length] = classification;
            }

            classifications = work;
            work = null;
            refreshTable();
        }

        function setContextKey() {
            var contextKey = "|";
            $find('aceClassification').set_contextKey(contextKey);
        }

        function togglePublish(controlKey) {
            var cbPublish = $("input[controlKey='" + controlKey + "']");

            var publish = "N";
            if (cbPublish.is(':checked'))
                publish = "Y";

            for (var j = 0; j < classifications.length; j++) {
                if (classifications[j].controlKey == controlKey) {
                    classifications[j].publish = publish;
                    break;
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
        <asp:HiddenField ID="hidClassifications" runat="server" />

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
                                                                                        <td width="10%" class="PANEREPEAT" nowrap="TRUE" valign="BOTTOM">Sequence Classifications</td>
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
                                                                                    <td style="width: 400px;">
                                                                                        <table style="width: 100%">
                                                                                            <tr>
                                                                                                <td valign="top">
                                                                                                    <table class="commodBorder" cellpadding="0" cellspacing="0" width="100%">
                                                                                                        <tr>
                                                                                                            <th class="commodBorder"></th>
                                                                                                            <th>Classification</th>
                                                                                                            <th />
                                                                                                            <th />
                                                                                                        </tr>
                                                                                                        <tbody id="tblClassifications" />
                                                                                                    </table>
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
            </script>
        </div>
    </form>
</body>
</html>