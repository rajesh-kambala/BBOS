<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PRTESFormBatchView.aspx.cs" Inherits="PRCo.BBS.CRM.PRTESFormBatchView" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>TES Form Batch View</title>
    
    <script type="text/javascript" src="../PRCoGeneral.js"></script>    
    <script type="text/javascript">
        function GenerateBatch() {
            var szWarning = "";
            var iRequestCount = parseInt(document.getElementById("hidTESRequestCount").value);
            if (iRequestCount >= 2000) {
                szWarning = "This is an unusually large number of requests.  GENERATING THIS BATCH MAY TAKE SEVERAL MINUTES.  ";
            }
            var szMessage = "There are " + document.getElementById("hidTESRequestCount").value + " requests ready to be batched.  " + szWarning + "Are you sure you want to continue?";

            if (confirm(szMessage))
                __doPostBack('btnGenerateBatch', '');

            return false;
        }


        function GenerateFiles() {
            if (ConfirmFiles())
                __doPostBack('btnGenerateFiles', '');

            return false;
        }

        function GenerateMailHouseFiles() {
            if (ConfirmFiles())
                __doPostBack('btnNewGenerateFiles', '');

            return false;           			    
        }


        function ConfirmFiles() {
            if (IsItemSelected("rbFormBatchID")) {
                return true;
            }

            alert('Please select a TES Batch to use to generate the export files.');
            return false;        
        }

        


    </script>

</head>
<body>
    <form id="form1" runat="server">
    <asp:Label ID="hidSID" visible="false" runat="server" />
    <asp:label id="lblMessage" runat="server" Font-Bold="True"/>
    <input type="hidden" id="hidTESRequestCount" runat="server" />

    <table width="100%" style="margin-top:5px;" cols="3">
    <tr>
    	<td style="width:15px;"></td>
        <td style="vertical-align:top;">
        
            <table width="100%" id="Table2" border="0">
            <tr>
                <td style="width:100%;" valign="top">

                    <table width="800px" border="0" cellpadding="0" cellspacing="0" rules="none" id="Table3">

                    <tr class="GridHeader">
                        <td colspan="2">
                            <table border="0" cellpadding="0" cellspacing="0" id="Table5">
                            <tr>
	                            <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                            <td style="white-space:nowrap" width="10%" class="PANEREPEAT">TES Form Batch View</td>
	                            <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/panelrightcorner.gif" hspace="0" border="0" align="top"/></td>
	                            <td style="vertical-align:bottom;" colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
                            </tr>
                            </table>
                        </td>
                    </tr>
                    <tr class="CONTENT">
                        <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                        <td width="100%" class="CONTENT">&nbsp;</td>
                        <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                    </tr>
                    <tr class="CONTENT">
                        <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                        <td HEIGHT="100%" width="100%" class="TABLEBORDERRIGHT">
    
                        <p></p>
                        <asp:Repeater ID=repBatches runat=server>
                        <HeaderTemplate>
                            The last <% =GetBatchListMax() %> batch records are displayed.
                            <table width=100% class=CONTENT border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff >
                            <tr>
                            <td class="GRIDHEAD">&nbsp;</td>
                            <td class="GRIDHEAD" align="center">Batch ID</td>
                            <td class="GRIDHEAD" align="center">Created Date/Time</td>
                            <td class="GRIDHEAD" align="center">Exported Date/Time</td>
                            <td class="GRIDHEAD" align="center">Form Count</td>
                            </tr>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <!-- <%# GetRowClass() %> -->
                            <tr>
                            <td class="<%# _szRowClass %>" align="center"><input type="radio" name="rbFormBatchID" value="<%# DataBinder.Eval(Container.DataItem, "prtfb_TESFormBatchID")%>" /></td>
                            <td class="<%# _szRowClass %>" align="center"><%# DataBinder.Eval(Container.DataItem, "prtfb_TESFormBatchID")%>&nbsp;</td>
                            <td class="<%# _szRowClass %>" align="center"><%# GetDateTime(DataBinder.Eval(Container.DataItem, "prtfb_CreatedDate")) %>&nbsp;</td>
                            <td class="<%# _szRowClass %>" align="center"><%# GetDateTime(DataBinder.Eval(Container.DataItem, "prtfb_LastFileCreation"))%>&nbsp;</td>
                            <td class="<%# _szRowClass %>" align="center"><%# ((int)DataBinder.Eval(Container.DataItem, "FormCount")).ToString("###,###,###")%>&nbsp;</td>
                            </tr>    
                        </ItemTemplate>        
                        </asp:Repeater>

                         <div id="pnlBatchesFooter" runat="server" visible="false">
                            <tr class="<%# GetRowClass() %>">
                                <td colspan=5>No TES Form Batches Found.</td>
                            </tr>
                         </div>
                         </table>

                        </td>
                        <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
                    </tr>

                    <tr height=1><td colspan="3" width="1px" class="TABLEBORDERBOTTOM"></td></tr>
                    </table>
                </td>
            </tr>
            </table>     
        </td>
        <td valign="top" width="5%" style="right:130px;padding-top:87.25px;">
				<table class="Button">
				<tr>
					<td class="Button">
						<table cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td><asp:HyperLink ID="imgbtnGenerateBatch" BorderStyle="None" ImageAlign="Middle" CssClass="er_buttonItemImg"  runat="server" /></td>
							<td></td>
							<td><asp:LinkButton ID="btnGenerateBatch" OnClick="btnGenerateBatchOnClick" Text="Generate Batch" CssClass="er_buttonItem" Target="_parent" runat="server" /></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td class="Button">
						<table cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td><asp:HyperLink ID="imgbtnGenerateFiles" BorderStyle="None" ImageAlign="Middle" CssClass="er_buttonItemImg"  runat="server" /></td>
							<td></td>
							<td><asp:LinkButton ID="btnGenerateFiles" OnClick="btnGenerateFilesOnClick" Text="Generate Files" CssClass="er_buttonItem" Target="_parent" runat="server" /></td>
						</tr>
						</table>
					</td>
				</tr>


				<tr>
					<td class="Button">
						<table cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td><asp:HyperLink ID="imgbtnNewGenerateFiles" BorderStyle="None" ImageAlign="Middle" CssClass="er_buttonItemImg"  runat="server" /></td>
							<td></td>
							<td><asp:LinkButton ID="btnNewGenerateFiles" OnClick="btnNewGenerateFilesOnClick" Text="Generate Mail House Files" CssClass="er_buttonItem" Target="_parent" runat="server" /></td>
						</tr>
						</table>
					</td>
				</tr>
                </table>
        </td>                                        
    </tr>
    </table>

    </form>
</body>
</html>
