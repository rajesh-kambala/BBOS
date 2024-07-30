<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PRDRCLicenseImportValidation.aspx.cs" Inherits="PRCo.BBS.CRM.PRDRCLicenseImportValidation" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Untitled Page</title>
    
    <script type="text/javascript">
        function upload() {
            if (confirm("Depending upon the size of the file, this action may take several minutes to complete.  Please do not click 'Upload' again.  Do you want to continue?")) {
                document.getElementById("frmEntry").action.value = "upload";
                document.getElementById("frmEntry").submit();
            }   	          
        }
        function pageContinue() {

        }
    </script>
    
</head>
<body>
    
    <table width="98%" ID="Table1" border=0>
    <tr>
        <td>&nbsp;</td>
        <td style="width:100%">
        
            <table ID="_icTable" width="100%">
            <tr>
                <td ID="_icTD">
                    <asp:label id="lblError" runat="server" Font-Bold="True"></asp:label>
                </td>
            </tr>
            </table>
                    
            <table width="100%" ID="Table2" border="0">
            <tbody>
            <tr><td style="width:100%" valign="top">

                <form id="frmEntry" method="post" runat="server" enctype="multipart/form-data">
                <input type="hidden" id="action" runat="server" />
                <asp:TextBox visible="False" id="hidSID" runat="server"/>
                <asp:TextBox visible="False" id="hidUserID" runat="server"/>

                <table width="100%" cellpadding="0" cellspacing="0" border="0" RULES="none" ID="Table3">
                <tr>
                    <td class="ROWGap" colspan="6">&nbsp;</td>
                </tr>
                <tr>
                    <td colspan="2">
                        <table cellpadding="0" cellspacing="0" border="0" ID="Table5">
                        <tr>
                            <td valign="bottom"><img alt="" src="/<%= _szAppName%>/img/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
                            <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Validate DRC License File</td>
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
                    <td HEIGHT="100%" width="100%" class="VIEWBOXCAPTION">
                        <table ID="Table6">
                        <tr><td width="504">
                            <span ID="_Captpril_fileDRCFileUpload" class="VIEWBOXCAPTION">DRC File:</span>
                            <br/>
                            <input type="file" runat="server" class="EDIT" size="80" id="fileDRCFileUpload"/>
                            </td>
                            <td>
                                <table cellpadding="0" cellspacing="0" border="0" ID="Table7">
                                <tr>
                                    <td width="32">
                                        <asp:HyperLink ID="lnkUploadImage" Cssclass="ButtonImage" runat="server"></asp:HyperLink></td>
                                    <td>&nbsp;</td>
                                    <td></td>
                                    <td><asp:HyperLink ID="lnkUpload" Cssclass="ButtonItem" runat="server"></asp:HyperLink></td>
                                </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td width="504"></td>
                        </tr>
                        </table>
                    </td>
                    <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                </tr>
                <tr style="line-height:1px;">
                    <td colspan="3" width="1" class="TABLEBORDERBOTTOM"></td>
                </tr>
                <tr>
                    <td class="ROWGap" colspan="6">&nbsp;</td>
                </tr>
                </table>
                                
                <asp:Panel id="pnlDRCFileStats" Visible="False" Runat="Server">
                           
                    <table width="100%" cellpadding="0" cellspacing="0" border="0" RULES="none" ID="Table4">
                    <tr><td class="ROWGap" colspan="6">&nbsp;</td></tr>
                    <tr><td colspan="2">
                        <table cellpadding="0" cellspacing="0" border="0" ID="Table8">
                        <tr>
                            <td valign="bottom"><img alt="" src="/<%= _szAppName%>/img/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
                            <td style="white-space:nowrap" width="10%" class="PANEREPEAT"><asp:Label id="lblDRCUnchangedCount" runat="server" /></td>
                            <td valign="bottom"><img alt="" src="/<%= _szAppName%>/img/backgrounds/panerightcorner.gif" hspace="0" border="0" align="top"/></td>
                            <td style="vertical-align:bottom;" class="TABLETOPBORDER">&nbsp;</td>
                            <td style="vertical-align:bottom;" class="TABLETOPBORDER">&nbsp;</td>
                            <td style="vertical-align:bottom;" colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
                        </tr>
                        </table>
                    </td></tr>
                    <tr class="CONTENT">
                        <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                        <td width="100%" class="CONTENT">&nbsp;</td>
                        <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                    </tr>
                    <tr class="CONTENT">
                        <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                        <td HEIGHT="100%" width="100%" class="VIEWBOXCAPTION">                                        

                        <!-- START MAIN CONTENT -->      
                        <asp:Table ID="tblUnchanged" runat="server"  Cssclass="Content" cellspacing="0" cellpadding="1" rules="all" border="1" style="border-width:1px;border-style:solid;height:20px;border-collapse:collapse;vertical-align:top; border-color:#ffffff;">
                        <asp:TableHeaderRow>
                            <asp:TableHeaderCell CssClass="GRIDHEAD" Text="Company ID"  />
                            <asp:TableHeaderCell CssClass="GRIDHEAD" Text="Company Name"  />
                            <asp:TableHeaderCell CssClass="GRIDHEAD" Text="DRC License Number" />
                        </asp:TableHeaderRow>
                        </asp:Table>                                        
                        <!-- END MAIN CONTENT -->                                        
                                                          
                        </td>
                        <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                    </tr>
                    <tr style="line-height:1px;"><td colspan="3" width="1" class="TABLEBORDERBOTTOM"></td></tr>
                    <tr><td class="ROWGap" colspan="6">&nbsp;</td></tr>
                    </table>

                    <table width="100%" cellpadding="0" cellspacing="0" border="0" RULES="none" ID="Table9">
                    <tr><td class="ROWGap" colspan="6">&nbsp;</td></tr>
                    <tr><td colspan="2">
                        <table cellpadding="0" cellspacing="0" border="0" ID="Table13">
                        <tr>
                            <td valign="bottom"><img alt="" src="/<%= _szAppName%>/img/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
                            <td style="white-space:nowrap" width="10%" class="PANEREPEAT"><asp:Label id="lblDRCChangeCount" runat="server" /></td>
                            <td valign="bottom"><img alt="" src="/<%= _szAppName%>/img/backgrounds/panerightcorner.gif" hspace="0" border="0" align="top"/></td>
                            <td style="vertical-align:bottom;" class="TABLETOPBORDER">&nbsp;</td>
                            <td style="vertical-align:bottom;" class="TABLETOPBORDER">&nbsp;</td>
                            <td style="vertical-align:bottom; " colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
                        </tr>
                        </table>
                    </td></tr>
                    <tr class="CONTENT">
                        <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                        <td width="100%" class="CONTENT">&nbsp;</td>
                        <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                    </tr>
                    <tr class="CONTENT">
                        <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                        <td HEIGHT="100%" width="100%" class="VIEWBOXCAPTION">                                        

                        <!-- START MAIN CONTENT -->
                        <asp:Table ID=tblChanged runat="server"  Cssclass="Content" cellspacing="0" cellpadding="1" rules="all" border="1" style="border-width:1px;border-style:solid;height:20px;border-collapse:collapse;vertical-align:top; border-color:#ffffff;">
                        <asp:TableHeaderRow>
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Source"  />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Company ID"  />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Company Name"  />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="DRC License Number" />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Status" />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Date Coverage"  />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Date Paid To"  />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Mailing Address" />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Physical Address"  />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Business Type" />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Contact Name" />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Job Title" />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Phone" />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Fax" />
                        </asp:TableHeaderRow>
                        </asp:Table>                                        
                        <!-- END MAIN CONTENT -->                                        
                        
                        </td>
                        <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                    </tr>
                    <tr style="line-height:1px;"><td colspan="3" width="1" class="TABLEBORDERBOTTOM"></td></tr>
                    <tr><td class="ROWGap" colspan="6">&nbsp;</td></tr>
                    </table>

                    <table width="100%" cellpadding="0" cellspacing="0" border="0" RULES="none" ID="Table14">
                    <tr><td class="ROWGap" colspan="6">&nbsp;</td></tr>
                    <tr><td colspan="2">
                        <table cellpadding="0" cellspacing="0" border="0" ID="Table15">
                        <tr>
                            <td valign="bottom"><img alt="" src="/<%= _szAppName%>/img/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
                            <td style="white-space:nowrap" width="10%" class="PANEREPEAT"><asp:Label id="lblDRCNewCount" runat="server" /></td>
                            <td valign="bottom"><img alt="" src="/<%= _szAppName%>/img/backgrounds/panerightcorner.gif" hspace="0" border="0" align="top"/></td>
                            <td style=" vertical-align:bottom;" class="TABLETOPBORDER">&nbsp;</td>
                            <td style=" vertical-align:bottom;" class="TABLETOPBORDER">&nbsp;</td>
                            <td style=" vertical-align:bottom; " colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
                        </tr>
                        </table>
                    </td></tr>
                    <tr class="CONTENT">
                        <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                        <td width="100%" class="CONTENT">&nbsp;</td>
                        <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                    </tr>
                    <tr class="CONTENT">
                        <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                        <td HEIGHT="100%" width="100%" class="VIEWBOXCAPTION">                                        

                        <!-- START MAIN CONTENT -->
                        <asp:Table ID=tblNew runat="server"  Cssclass="Content" cellspacing="0" cellpadding="1" rules="all" border="1" style="border-width:1px;border-style:solid;height:20px;border-collapse:collapse;vertical-align:top; border-color:#ffffff;">
                        <asp:TableHeaderRow>
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Source"  />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Company ID"  />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Company Name"  />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="DRC License Number" />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Status" />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Date Coverage"  />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Date Paid To"  />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Mailing Address" />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Physical Address"  />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Business Type" />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Contact Name" />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Job Title" />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Phone" />
                            <asp:TableHeaderCell CssClass=GRIDHEAD Text="Fax" />
                        </asp:TableHeaderRow>
                        </asp:Table>                                        
                    
                        <!-- END MAIN CONTENT -->                                        
                        
                        
                        </td>
                        <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                    </tr>
                    <tr style="line-height:1px;"><td colspan="3" width="1" class="TABLEBORDERBOTTOM"></td></tr>
                    <tr><td class="ROWGap" colspan="6">&nbsp;</td></tr>
                    </table>
                                   
                </asp:Panel>
                                
               </form>
            </td></tr>
            </tbody>
            </table>
        </td>
    </tr>
    </table>
</body>
</html>
