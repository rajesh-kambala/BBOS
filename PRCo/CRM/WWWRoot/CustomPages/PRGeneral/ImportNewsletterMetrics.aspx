<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ImportNewsletterMetrics.aspx.cs" Inherits="PRCo.BBS.CRM.CustomPages.PRGeneral.ImportNewsletterMetrics" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"></script>
</head>

<body>
    <form id="form1" runat="server">

        <table width="100%" style="margin-top: 5px;" cols="3">
            <tr>
                <td style="width: 15px;"></td>
                <td style="vertical-align: top;">
                    <table id="_icTable" width="100%">
                        <tr>
                            <td id="_icTD">
                                <asp:Label ID="lblError" runat="server" Font-Bold="True" ForeColor="Red" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblTotalCount" CssClass="VIEWBOXCAPTION" runat="server" /></td>
                        </tr>
                    </table>
                    <table width="100%" id="Table2" border="0">
                        <tbody>
                            <tr>
                                <td style="width: 90%;" valign="top">

                                    <input type="hidden" id="action" runat="server" />
                                    <asp:TextBox Visible="False" ID="hidSID" runat="server" />
                                    <asp:TextBox Visible="False" ID="hidUserID" runat="server" />

                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" rules="none" id="Table3">
                                        <tr class="GridHeader">
                                            <td colspan="2">
                                                <table border="0" cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td style="vertical-align: bottom;" class="PanelCorners">
                                                            <img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top" /></td>
                                                        <td style="white-space: nowrap" width="10%" class="PANEREPEAT">Import Newsletter Metrics</td>
                                                        <td style="vertical-align: bottom;" class="PanelCorners">
                                                            <img alt="" src="/crm/Themes/img/ergonomic/backgrounds/panelrightcorner.gif" hspace="0" border="0" align="top" /></td>
                                                        <td style="vertical-align: bottom;" colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr class="CONTENT">
                                            <td style="width: 1" class="TABLEBORDERLEFT">
                                                <img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" style="margin: 0; border: 0; text-align: top" /></td>
                                            <td style="width: 100%" class="CONTENT">&nbsp;</td>
                                            <td style="width: 1" class="TABLEBORDERRIGHT">
                                                <img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" style="margin: 0; border: 0; text-align: top" /></td>
                                        </tr>
                                        <tr class="CONTENT">
                                            <td style="width: 1" class="TABLEBORDERLEFT">
                                                <img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" style="margin: 0; border: 0; text-align: top" /></td>
                                            <td style="height: 100%; width: 100%">
                                                <table id="Table6">
                                                    <tr>
                                                        <td style="width: 504px">
                                                            <span id="_Captpril_fileThirdPartyNewsUpload" class="VIEWBOXCAPTION">Newsletter Metrics File:</span>
                                                            <br />
                                                            <asp:FileUpload CssClass="EDIT" runat="server" ID="fileUpload" Width="500px" />
                                                            <br /><br />
                                                        </td>
                                                    </tr>

                                                    <tr>
                                                        <td style="width: 504px">
                                                            <span id="_Captpril_OriginalEmailSentCount" class="VIEWBOXCAPTION">Original # of Emails Sent:</span>
                                                            <br />
                                                            <asp:TextBox ID="txtOrigEmailsSentCount" runat="server" CssClass="number" />
                                                            <br /><br />
                                                        </td>
                                                    </tr>

                                                    <tr>
                                                        <td style="width: 504px">
                                                            <span id="_Captpril_SentDate" class="VIEWBOXCAPTION">Date Sent:</span>
                                                            <br />
                                                            <asp:TextBox ID="txtSentDate" runat="server" />
                                                            <br /><br />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:HyperLink ID="lnkUpload" CssClass="er_buttonItem" runat="server"></asp:HyperLink>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td style="width: 1" class="TABLEBORDERRIGHT">
                                                <img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" style="margin: 0; border: 0; text-align: top" /></td>
                                        </tr>
                                        <tr height="1">
                                            <td colspan="3" width="1px" class="TABLEBORDERBOTTOM"></td>
                                        </tr>
                                        <tr>
                                            <td class="ROWGap" colspan="6">&nbsp;</td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
        </table>

        <script type="text/javascript">
            $(document).ready(function () {
                if ($("#<%=txtSentDate.ClientID%>").val() == '') {
                    $("#<%=txtSentDate.ClientID%>").datepicker({ dateFormat: 'mm/dd/yy' }).datepicker("setDate", new Date());
                }
                else {
                    $("#<%=txtSentDate.ClientID%>").datepicker({ dateFormat: 'mm/dd/yy' });
                }

                $(".number").bind('keydown', function (e) {
                    var key = e.keyCode ? e.keyCode : e.which;

                    if (!([8, 9, 13, 27, 46, 110, 190].indexOf(key) !== -1 ||
                        (key == 65 && (e.ctrlKey || e.metaKey)) ||
                        (key >= 35 && key <= 40) ||
                        (key >= 48 && key <= 57 && !(e.shiftKey || e.altKey)) ||
                        (key >= 96 && key <= 105)
                    )) e.preventDefault();
                });
            });
        </script>
    </form>
</body>
</html>
