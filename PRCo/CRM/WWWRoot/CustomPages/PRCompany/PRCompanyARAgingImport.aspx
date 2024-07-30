<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PRCompanyARAgingImport.aspx.cs" Inherits="PRCo.BBS.CRM.PRCompanyARAgingImport" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Company A/R Aging File Import</title>
</head>
<body>
    <script type="text/javascript">
        function upload() {
            document.getElementById("frmEntry").action.value = "upload";
            document.getElementById("frmEntry").submit();
        }
        function pageContinue() {
            window.top.location.href = "/<%= _szAppName %>/CustomPages/PRCompany/PRCompanyARAgingByListing.asp?SID=<%= sSID %>&Key0=1&Key1=<% =_iCompanyID %>&T=Company&Capt=Trade+Activity";
        }
    </script>
    
    <table width="100%" id="Table1">
    <tr>
        <td>&nbsp;</td>
        <td style="width:99%;">
            <table id="_icTable" width="100%">
            <tr>
                <td id="_icTD">
                    <asp:label id="lblError" runat="server" Font-Bold="True"></asp:label>
                </td>
            </tr>
            </table>

            <table width="100%" id="Table2" border="0">
            <tbody>
            <tr>
                <td style="width:90%;" valign="top">
                    <form id="frmEntry" method="post" runat="server" enctype="multipart/form-data">
                        <asp:ScriptManager  id ="ScriptManager1" runat="server" />
                        <input type="hidden" id="action" runat="server" />
                        <asp:TextBox visible="false" id="hidSID" runat="server"/>
                        <asp:TextBox visible="false" id="hidCompanyID" runat="server"/>
                        <asp:TextBox visible="false" id="hidUserID" runat="server"/>

                        <table width="100%" cellpadding="0" cellspacing="0" border="0" RULES="none" id="Table3">
                        <tr>
                            <td class="ROWGap" colspan="6">&nbsp;</td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <table cellpadding="0" cellspacing="0" border="0" id="Table5">
                                <tr>
                                    <td valign="bottom"><img alt="" src="/<%= _szAppName%>/img/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
                                    <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Import A/R Aging Files</td>
                                    <td valign="bottom"><img alt="" src="/<%= _szAppName%>/img/backgrounds/panerightcorner.gif" hspace="0" border="0" align="top"/></td>
                                    <td style=" vertical-align:bottom;" class="TABLETOPBORDER">&nbsp;</td>
                                    <td style=" vertical-align:bottom;" class="TABLETOPBORDER">&nbsp;</td>
                                    <td style=" vertical-align:bottom; " colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
                                </tr>
                                </table>
                            </td>
                        </tr>
                        <tr class="CONTENT">
                            <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                            <td width="100%" class="CONTENT">&nbsp;</td>
                            <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                        </tr>
                        <tr class="CONTENT">
                            <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                            <td height="100%" width="100%" class="VIEWBOXCAPTION">
                                <table id="Table6">
                                <tr>
                                    <td width="504">
                                        <span id="SPAN1" class="VIEWBOXCAPTION">A/R Aging File Format:</span>
                                        <br/>
                                        <asp:Label CssClass="VIEWBOX" ID="lblFileFormatName" runat="server" />
                                    </td>
                                </tr>

                                <asp:Panel ID="pnlARAgingDate" runat="server" Visible="false">
                                <tr>
                                    <td width="504">
                                        <span id="SPAN2" class="VIEWBOXCAPTION">A/R Aging Date:</span>
                                        <br/>
                                        <asp:TextBox runat="server" CssClass="EDIT" Columns="10" id="txtARAgingDate" />
                                        <asp:ImageButton runat="Server" id="imgARAgingDate" />
                                        <cc1:CalendarExtender runat="server" id="ceARAgingDate" TargetControlid="txtARAgingDate" PopupButtonid="imgARAgingDate" />
                                    </td>
                                </tr>
                                </asp:Panel>

                                <tr>
                                    <td width="504">
                                        <span ID="_Captpril_fileARAgingUpload" class="VIEWBOXCAPTION">A/R Aging File:</span>
                                        <br/>
                                        <input type="file" runat="server" class="EDIT" size="80" id="fileARAgingUpload"/>
                                    </td>
                                    <td>
                                        <table cellpadding="0" cellspacing="0" border="0" id="Table7">
                                        <tr>
                                            <td width="32">
                                                <asp:HyperLink id="lnkUploadImage" Cssclass="ButtonImage" runat="server"></asp:HyperLink></td>
                                            <td>&nbsp;</td>
                                            <td></td>
                                            <td><asp:HyperLink id="lnkUpload" Cssclass="ButtonItem" runat="server"></asp:HyperLink></td>
                                        </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="504">
                                        <asp:Panel id="pnlARAgingStats" Visible="False" Runat="Server">
                                            <table cellpadding="0" cellspacing="0" border="0" id="tblARAgingeStats">
                                            <tr>
                                                <td><asp:Label id="lblARAgingCount" Cssclass="DisplayText" runat="server"></asp:Label></td>
                                            </tr>
                                            <tr>
                                                <td><asp:Label id="lblARAgingUnmatchedCount" Cssclass="DisplayText" runat="server"></asp:Label></td>
                                            </tr>
                                            <tr>
                                                <td><asp:Label id="lblSkippedLineCount" Cssclass="DisplayText" runat="server"></asp:Label></td>
                                            </tr>
                                            </table>
                                        </asp:Panel>
                                    </td>
                                </tr>
                                </table>
                            </td>
                            <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                        </tr>
<tr height=1><td colspan="3" width="1px" class="TABLEBORDERBOTTOM"></td></tr>
                        <tr>
                            <td class="ROWGap" colspan="6">&nbsp;</td>
                        </tr>
                        </table>
    
                    </form>
                </td>
                <td valign="top">
                    <table id="Table10">
                    <tr>
                        <td height="29">&nbsp;</td>
                    </tr>
                    </table>
                    <table class="Button" width="100" id="Table11">
                    <tr>
                        <td class="ButtonItem">
                            <table cellpadding="0" cellspacing="0" border="0" id="Table12">
                            <tr>
                                <td width="32"><asp:HyperLink id="lnkContinueImage" Cssclass="ButtonImage" runat="server"></asp:HyperLink></td>
                                <td>&nbsp;</td>
                                <td></td>
                                <td><asp:HyperLink id="lnkContinue"  Cssclass="ButtonItem" runat="server"></asp:HyperLink></td>
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

