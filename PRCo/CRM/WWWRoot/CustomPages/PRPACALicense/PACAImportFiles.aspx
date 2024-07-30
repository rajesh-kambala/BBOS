<%@ Page language="c#" AutoEventWireUp="true" Inherits="PRCo.BBS.CRM.PACAImportFiles" Codebehind="PACAImportFiles.aspx.cs" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%
    string SID = Request.Params.Get("SID");
    //Response.Write (Request.ServerVariables.Get("URL") + "?" + Request.QueryString); 
%>                      

<html xmlns="http://www.w3.org/1999/xhtml" >
    <head>
        <title>Import PACA Files</title>
        <link rel="stylesheet" href="/<%= sAppName%>/eware.css" />
        <link rel="stylesheet" href="/<%= sAppName%>/prco.css" />
        <script type="text/javascript">
	        function upload() {
	            document.getElementById("frmEntry").action.value = "upload";
	            document.getElementById("frmEntry").submit();
	        }
	        function pageContinue() {
		        location.href="/<%= sAppName %>/CustomPages/PRPACALicense/PRImportPACALicenseFind.asp?SID=<%= SID %>";
	        }
        </script>
    </head>
    <body>
        <asp:Label id="lblMessage" runat="server"></asp:Label>
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
                            <input type="hidden" id="action" runat="server" />
                            <asp:TextBox visible="False" id="hidSID" runat="server"></asp:TextBox>
                            <table width="100%" cellpadding="0" cellspacing="0" border="0" RULES="none" id="Table3">
                            <tr>
                                <td class="ROWGap" colspan="6">&nbsp;</td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <table cellpadding="0" cellspacing="0" border="0" id="Table5">
                                    <tr>
                                        <td valign="bottom"><img alt="" src="/<%= sAppName%>/img/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
                                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">PACA Upload Files</td>
                                        <td valign="bottom"><img alt="" src="/<%= sAppName%>/img/backgrounds/panerightcorner.gif" hspace="0" border="0" align="top"/></td>
                                        <td style="vertical-align:bottom;" class="TABLETOPBORDER">&nbsp;</td>
                                        <td style="vertical-align:bottom;" class="TABLETOPBORDER">&nbsp;</td>
                                        <td style="vertical-align:bottom;" colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
                                    </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr class="CONTENT">
                                <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= sAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                                <td width="100%" class="CONTENT">&nbsp;</td>
                                <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= sAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                            </tr>
                            <tr class="CONTENT">
                                <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= sAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                                <td height="100%" width="100%" class="VIEWBOXCAPTION">

                                    <table id="Table6">
                                    <tr>
                                        <td width="504">
                                            <span id="_Captpril_fileLicenseUpload" class="VIEWBOXCAPTION">License File:</span>
                                            <br/>
                                            <input type="file" runat="server" class="EDIT" size="80" id="fileLicenseUpload"/>
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
                                            <asp:Panel id="pnlLicenseStats" Visible="false" Runat="server">
                                                <table cellpadding="0" cellspacing="0" border="0" id="tblLicenseStats">
                                                <tr>
                                                    <td><asp:Label id="lblLicenseSuccess" Cssclass="DisplayText" runat="server"></asp:Label></td>
                                                </tr>
                                                <tr>
                                                    <td><asp:Label id="lblLicenseFailed" Cssclass="DisplayText" runat="server"></asp:Label></td>
                                                </tr>
                                                <tr>
                                                    <td><asp:Label id="lblLicenseMatched" Cssclass="DisplayText" runat="server"></asp:Label></td>
                                                </tr>
                                                <tr>
                                                    <td><asp:Label id="lblLicenseWrongFormat" Cssclass="DisplayText" runat="server"></asp:Label></td>
                                                </tr>
                                                </table>
                                            </asp:Panel>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="504" colspan="2">
                                            <span ID="_Captpril_filePrincipalUpload" class="VIEWBOXCAPTION">Principal File:</span>
                                            <br/>
                                            <input type="file" runat="server" class="EDIT" size="80" id="filePrincipalUpload"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="504">
                                            <asp:Panel id="pnlPrincipalStats" Visible="false" Runat="server">
                                                <table cellpadding="0" cellspacing="0" border="0" id="tblPrincipalStats">
                                                <tr>
                                                    <td><span id="_CaptPrincipalSuccess" class="DisplayText">Successfully Loaded:</span></td>
                                                    <td>&nbsp;</td>
                                                    <td><asp:Label id="lblPrincipalSuccess" Cssclass="DisplayText" runat="server"></asp:Label></td>
                                                </tr>
                                                <tr>
                                                    <td><span id="_CaptPrincipalFailed" class="DisplayText">Failed Records:</span></td>
                                                    <td>&nbsp;</td>
                                                    <td><asp:Label id="lblPrincipalFailed" Cssclass="DisplayText" runat="server"></asp:Label></td>
                                                </tr>
                                                <tr>
                                                    <td><span id="_CaptPrincipalWrongFormat" class="DisplayText">Wrong Format:</span></td>
                                                    <td>&nbsp;</td>
                                                    <td><asp:Label id="lblPrincipalWrongFormat" Cssclass="DisplayText" runat="server"></asp:Label></td>
                                                </tr>
                                                </table>
                                            </asp:Panel>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="504" colspan="2">
                                            <span id="_Captpril_fileTradeUpload" class="VIEWBOXCAPTION">Trade File:</span>
                                            <br/>
                                            <input type="file" runat="server" class="EDIT" size="80" id="fileTradeUpload"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="504">
                                            <asp:Panel id="pnlTradeStats" Visible="false" Runat="server">
                                                <table cellpadding="0" cellspacing="0" border="0" id="tblTradeStats">
                                                <tr>
                                                    <td><span id="_CaptTradeSuccess" class="DisplayText">Successfully Loaded:</span></td>
                                                    <td>&nbsp;</td>
                                                    <td><asp:Label id="lblTradeSuccess" Cssclass="DisplayText" runat="server"></asp:Label></td>
                                                </tr>
                                                <tr>
                                                    <td><span id="_CaptTradeFailed" class="DisplayText">Failed Records:</span></td>
                                                    <td>&nbsp;</td>
                                                    <td><asp:Label id="lblTradeFailed" Cssclass="DisplayText" runat="server"></asp:Label></td>
                                                </tr>
                                                <tr>
                                                    <td><span id="_CaptTradeWrongFormat" class="DisplayText">Wrong Format:</span></td>
                                                    <td>&nbsp;</td>
                                                    <td><asp:Label id="lblTradeWrongFormat" Cssclass="DisplayText" runat="server"></asp:Label></td>
                                                </tr>
                                                </table>
                                            </asp:Panel>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="504" colspan="2">
                                            <span id="_Captpril_fileComplaintUpload" class="VIEWBOXCAPTION">Complaint File:</span>
                                            <br/>
                                            <input type="file" runat="server" class="EDIT" size="80" id="fileComplaintUpload"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="504">
                                            <asp:Panel id="pnlComplaintStats" Visible="false" Runat="server">
                                                <table cellpadding="0" cellspacing="0" border="0" id="tblComplaintStats">
                                                <tr>
                                                    <td><span id="_CaptComplaintSuccess" class="DisplayText">Successfully Loaded:</span></td>
                                                    <td>&nbsp;</td>
                                                    <td><asp:Label id="lblComplaintSuccess" Cssclass="DisplayText" runat="server"></asp:Label></td>
                                                </tr>
                                                <tr>
                                                    <td><span id="_CaptComplaintFailed" class="DisplayText">Failed Records:</span></td>
                                                    <td>&nbsp;</td>
                                                    <td><asp:Label id="lblComplaintFailed" Cssclass="DisplayText" runat="server"></asp:Label></td>
                                                </tr>
                                                <tr>
                                                    <td><span id="_CaptComplaintWrongFormat" class="DisplayText">Wrong Format:</span></td>
                                                    <td>&nbsp;</td>
                                                    <td><asp:Label id="lblComplaintWrongFormat" Cssclass="DisplayText" runat="server"></asp:Label></td>
                                                </tr>
                                                </table>
                                            </asp:Panel>
                                        </td>
                                    </tr>
                                    </table>

                                </td>
                                <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= sAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                            </tr>
                            <tr style="line-height:1px;">
                                <td colspan="3" width="1" class="TABLEBORDERBOTTOM"></td>
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
