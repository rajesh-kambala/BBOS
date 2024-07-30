<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PRCreditSheetExport.aspx.cs" Inherits="PRCo.BBS.CRM.PRCreditSheetExport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Credit Sheet Export</title>
</head>
<body>

    <table style="width:100%" id="Table1">
    <tr>
        <td>&nbsp;</td>
        <td style="width:99%;">
                    <table id="_icTable" style="width:100%">
                        <tr>
                            <td id="_icTD">
                                <asp:label id="lblError" runat="server" Font-Bold="True"></asp:label>
                            </td>
                        </tr>
                    </table>
                    <table style="width:100%" id="Table2" border="0">
                        <tbody>
                            <tr>
                                <td style="width:90%;" valign="top">
                                    <form id="frmEntry" method="post" runat="server" >
                                        <input type="hidden" id="action" runat="server" />
                                        <asp:TextBox visible="False" id="hidSID" runat="server"/>
                                        <asp:TextBox visible="False" id="hidUserID" runat="server"/>

                                        <table style="width:100%" border="0" cellpadding="0" cellspacing="0" rules="none" id="Table3">
                                            <tr>
                                                <td class="ROWGap" colspan="6">&nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <table cellpadding="0" cellspacing="0" id="Table5">
                                                        <tr>
                                                            <td valign="bottom"><img alt="" src="/<%= _szAppName%>/img/backgrounds/paneleftcorner.jpg" style="margin:0 0; text-align:top"/></td>
                                                            <td style="white-space:nowrap; width:10%" class="PANEREPEAT">Export Credit Sheet Data</td>
                                                            <td valign="bottom"><img alt="" src="/<%= _szAppName%>/img/backgrounds/panerightcorner.gif" style="margin: 0 0; text-align:top" /></td>
                                                            <td style=" vertical-align:bottom;" class="TABLETOPBORDER">&nbsp;</td>
                                                            <td style=" vertical-align:bottom;" class="TABLETOPBORDER">&nbsp;</td>
                                                            <td style=" vertical-align:bottom; width:90%" colspan="30" class="TABLETOPBORDER">&nbsp;</td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr class="CONTENT">
                                                <td style="width:1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" style="margin:0 0; text-align:top" /></td>
                                                <td style="width:100%" class="CONTENT">&nbsp;</td>
                                                <td style="width:1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" style="margin:0 0; text-align:top" /></td>
                                            </tr>
                                            <tr class="CONTENT">
                                                <td style="width:1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" style="margin:0 0; text-align:top" /></td>
                                                <td style="height:100%; width:100%" class="VIEWBOXCAPTION">
                                                    <table id="Table6">
                                                        <tr>
                                                             <td style="width:504">
                                                                <span id="SPAN2" class="VIEWBOXCAPTION">Include Items Exported on Date:</span>
                                                                <br/>
                                                                <asp:TextBox runat="server" CssClass="EDIT" Columns="10" id="txtIncludeDate" />
                                                            </td>
                                                        </tr>

                                                        <tr>
                                                            <td>
                                                            <br/>
                                                                <asp:Button id="btnFriday"  Width="400" Text="Friday Item Export to Express Update" OnClick="btnFridayOnClick" runat="server" />
                                                                <table border="0">
                                                                    <tr>
                                                                        <td><span class="VIEWBOXCAPTION">Express Update Last Exported on:</span></td>
                                                                        <td><asp:Literal id="litFridayExpressFileDate" runat="server"></asp:Literal></td>
                                                                    </tr>
                                                                </table>
                                                                <br />&nbsp;<br />
                                                                <asp:Button id="btnWednesday"  Width="400" Text="Wednesday Item Export to Express Update and Credit Sheet" OnClick="btnWednesdayOnClick" runat="server" />
                                                                <table border="0">
                                                                    <tr>
                                                                        <td><span class="VIEWBOXCAPTION">Express Update Last Exported on:</span></td><td><asp:Literal id="litWednesdayExpressFileDate" runat="server"></asp:Literal></td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td><span class="VIEWBOXCAPTION">Credit Sheet Last Exported on:</span></td>
                                                                        <td><asp:Literal id="litWednesdayCreditSheetFileDate" runat="server"></asp:Literal></td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="width:504">
                                                                <asp:Panel id="pnlCreditsSheetStats" Visible="False" Runat="Server">
                                                                    <table cellpadding="0" cellspacing="0" >
                                                                    <tr>
                                                                        <td><asp:Label id="lblCreditSheetCount" CssClass="DisplayText" runat="server"></asp:Label></td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td><asp:Label id="lblExpressCount" CssClass="DisplayText" runat="server"></asp:Label></td>
                                                                    </tr>
                                                                    </table>
                                                                </asp:Panel>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td style="width:1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" style="margin:0 0; text-align:top" /></td>
                                            </tr>
                                            <tr style="line-height:1px;">
                                                <td colspan="3" style="width:1" class="TABLEBORDERBOTTOM"></td>
                                            </tr>
                                            <tr>
                                                <td class="ROWGap" colspan="6">&nbsp;</td>
                                            </tr>
                                        </table>
                                    </form>
                                </td>
                                <td valign="top">
                                        <table id="Table10">
                                            <tr>
                                                <td style="height:29">&nbsp;</td>
                                            </tr>
                                        </table>
                                        <table class="Button" style="width:100" id="Table11">
                                            <tr>
                                                <td class="ButtonItem">
                                                    <table cellpadding="0" cellspacing="0" id="Table12">
                                                        <tr>
                                                            <td style="width:32"><asp:HyperLink id="lnkContinueImage" CssClass="ButtonImage" runat="server"></asp:HyperLink></td>
                                                            <td>&nbsp;</td>
                                                            <td></td>
                                                            <td><asp:HyperLink id="lnkContinue"  CssClass="ButtonItem" runat="server"></asp:HyperLink></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                </td>                                        
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
        </table>


</body>
</html>
