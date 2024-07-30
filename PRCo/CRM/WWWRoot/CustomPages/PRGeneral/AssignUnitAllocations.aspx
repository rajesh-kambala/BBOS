<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AssignUnitAllocations.aspx.cs" Inherits="PRCo.BBS.CRM.PRGeneral.AssignUnitAllocations" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    <table width="100%" id="Table1">
    <tr>
        <td>&nbsp;</td>
        <td style="width:99%;">
            <table id="_icTable" width="100%">
            <tr>
                <td id="_icTD" align="center">
                    <asp:label id="lblError" runat="server" Font-Bold="True" ForeColor="Red"/>
                </td>
            </tr>
            <tr>
                <td align="center"><asp:Label id="lblThirdPartyCount" CssClass="VIEWBOXCAPTION" runat="server" /></td>   
            </tr>
            </table>
            <table width="100%" id="Table2" border="0">
                <tbody>
                <tr>
                    <td style="width:90%;" valign="top">

                        <input type="hidden" id="action" runat="server" />
                        <asp:TextBox visible="False" id="hidSID" runat="server"/>
                        <asp:TextBox visible="False" id="hidUserID" runat="server"/>

                        <table width="100%" border="0" cellpadding="0" cellspacing="0" rules="none" id="Table3">
                        <tr>
                            <td class="ROWGap" colspan="6">&nbsp;</td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <table border="0" cellpadding="0" cellspacing="0" id="Table5">
                                <tr>
                                    <td valign="bottom"><img alt="" src="/<%= _szAppName%>/img/backgrounds/paneleftcorner.jpg" style="margin:0; border:0; text-align:top"/></td>
                                    <td style="white-space:nowrap; width:10%" class="PANEREPEAT">Assign Unit Allocations</td>
                                    <td valign="bottom"><img alt="" src="/<%= _szAppName%>/img/backgrounds/panerightcorner.gif" style="margin:0; border:0; text-align:top"/></td>
                                    <td style=" vertical-align:bottom;" class="TABLETOPBORDER">&nbsp;</td>
                                    <td style=" vertical-align:bottom;" class="TABLETOPBORDER">&nbsp;</td>
                                    <td style=" vertical-align:bottom; width:90%" colspan="30" class="TABLETOPBORDER">&nbsp;</td>
                                </tr>
                                </table>
                            </td>
                        </tr>
                        <tr class="CONTENT">
                            <td style="width:1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" style="margin:0; border:0; text-align:top"/></td>
                            <td style="width:100%" class="CONTENT">&nbsp;</td>
                            <td style="width:1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" style="margin:0; border:0; text-align:top"/></td>
                        </tr>
                        <tr class="CONTENT">
                            <td style="width:1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" style="margin:0; border:0; text-align:top"/></td>
                            <td style="height:100%; width:100%">
                                <table id="Table6">
                                <tr>
                                    <td style="width:300px">
                                        <span class="VIEWBOXCAPTION">Company IDs:</span><br/>
                                        <asp:TextBox ID="txtCompanyIDs" runat="server" />
                                    
                                    </td>                                

                                    <td style="width:504px">
                                        <span class="VIEWBOXCAPTION">Expiration Date:</span>
                                        <br/>
                                        <asp:TextBox ID="txtExpirationDate" runat="server" Columns="10" MaxLength="10" />
                                        <asp:CalendarExtender ID="CalendarExtender1" 
                                         TargetControlID="txtExpirationDate"
                                        runat="server" />
                                    </td>
                                    <td>
                                        <span id="Span1" class="VIEWBOXCAPTION">Units:</span>
                                        <br/>
                                        <asp:TextBox ID="txtUnits" runat="server" Columns="5" MaxLength="5" />
                                    </td>
                                </tr>
                                </table>
                            </td>
                            <td style="width:1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" style="margin: 0; border:0; text-align:top"/></td>
                        </tr>
                        <tr style="line-height:1px;">
                            <td colspan="3" style="width:1" class="TABLEBORDERBOTTOM"></td>
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


    </div>
    </form>
</body>
</html>
