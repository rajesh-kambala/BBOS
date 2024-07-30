<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ImportInteractions.aspx.cs" Inherits="PRCo.BBS.CRM.ImportInteractions" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Interactions Import</title>
</head>
<body>
    
    <table width="100%" style="margin-top:5px;" cols="3">
    <tr>
        <td style="width:15px;"></td>
        <td style="vertical-align:top;">
            <table id="_icTable" width="100%">
                <tr>
                    <td id="_icTD">
                        <asp:label id="lblError" runat="server" Font-Bold="True" ForeColor="Red"></asp:label>
                    </td>
                </tr>
            </table>

            <form id="frmEntry" method="post" runat="server" enctype="multipart/form-data">            
            <table width="100%" border="0" cellpadding="0" cellspacing="0">
            <tbody>
                <tr>
                <td style="width:90%;" valign="top">
                        <input type="hidden" id="action" runat="server" />
                        <asp:TextBox visible="False" id="hidSID" runat="server"/>
                        <asp:TextBox visible="False" id="hidUserID" runat="server"/>

                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                        <tr class="GridHeader">
                            <td colspan="2">
                                <table border="0" cellpadding="0" cellspacing="0">
                                    <tr>
	                                    <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                                    <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Import Interactions</td>
	                                    <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/panelrightcorner.gif" hspace="0" border="0" align="top"/></td>
	                                    <td style="vertical-align:bottom;" colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
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
                                    <td style="width:504">
                                        <span id="_Captpril_fileUpload" class="VIEWBOXCAPTION">Import File:</span>
                                        <br/>
                                        <input type="file" runat="server" class="EDIT" size="80" id="fileUpload"/>
                                    </td>
                                    <td>
                                        <table class="Button">
				                        <tr>
					                        <td class="Button">
						                        <table cellpadding="0" cellspacing="0" border="0">
						                        <tr>
							                        <td><asp:ImageButton OnClick="ImportClick" id="lnkUploadImage" CssClass="er_buttonItemImg" runat="server" BorderStyle="None"></asp:ImageButton></td>
							                        <td></td>
							                        <td><asp:LinkButton OnClick="ImportClick" id="lnkUpload" CssClass="er_buttonItem" runat="server"></asp:LinkButton></td>
						                        </tr>
						                        </table>
                                            </td>
                                        </tr>
                                        </table>
					                </td>
				                </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <asp:Panel id="pnlImportStats" Visible="False" Runat="Server">
                                    <table cellpadding="0" cellspacing="0" border="0" id="tblStats">
                                    <tr>
                                        <td><asp:Label id="lblRecordCount" CssClass="VIEWBOXCAPTION" runat="server"></asp:Label></td>
                                    </tr>
                                    </table>
                                </asp:Panel>
                            </td>
                        </tr>
                        </table>
                    </td>
                    <td style="width:1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" style="margin: 0; border:0; text-align:top"/></td>
                </tr>
                <tr height=1><td colspan="3" width="1px" class="TABLEBORDERBOTTOM"></td></tr>
            </tbody>
            </table>
            </form>
        </td>
    </tr>
    </table>
</body>
</html>
