<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GenerateInvoices.aspx.cs" Inherits="PRCo.BBS.CRM.GenerateInvoices" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
	<style>
		a[disabled], a[disabled]:hover {
		   pointer-events: none;
		   color: #e1e1e1;
		}
	</style>
	<script type="text/javascript">

		function confirmSendEmails() {

			if (confirm('Are you sure you want to generate and send email/fax invoices?')) {
				document.getElementById("btnGenerateEmailFaxInvoices").disabled = true;
				document.getElementById("btnGenerateEmailFaxInvoices").style.pointerEvents = "none";
				document.getElementById("btnGenerateEmailFaxInvoices").setAttribute("disabled", "true");

                document.getElementById("btnGenerateSendEmailFaxInvoices").disabled = true;
                document.getElementById("btnGenerateSendEmailFaxInvoices").style.pointerEvents = "none";
                document.getElementById("btnGenerateSendEmailFaxInvoices").setAttribute("disabled", "true");

				document.getElementById("lblMsg").innerHTML = "Generating and sending invoices...";
				return true;
			}

			return false;
		}

		function toggleInclusion() {
			var inclusion = document.getElementById("ddlInclusionType").value;

            if (inclusion == "P")
                document.getElementById("ddlElectronicBatchList").disabled = true;
			else
                document.getElementById("ddlElectronicBatchList").disabled = false;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:TextBox visible="false" id="hidSID" runat="server"/>
    <asp:TextBox visible="false" id="hidUserID" runat="server"/>

<table width="100%" style="margin-top:5px;" cols="3">
<tr>
    <td style="vertical-align:top;">
    
        <table width="100%">
        <tr>
            <td>
                <asp:label id="lblMsg" runat="server" Font-Bold="True" ForeColor="Red"></asp:label>
            </td>
        </tr>
        </table>
    
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tbody>
        <tr>
        	<td style="width:95%;" valign="top">

   				<table width="100%" border="0" cellpadding="0" cellspacing="0">
        		<tr class="GridHeader">
		            <td colspan="2">
        		        <table  border="0" cellpadding="0" cellspacing="0">
                	    <tr>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Mail Invoicing</td>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/panelrightcorner.gif" hspace="0" border="0" align="top"/></td>
	                        <td style="vertical-align:bottom;" colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
	                    </tr>
	                	</table>
            		</td>
        		</tr>
			
				<!-- Blank Row -->	
		        <tr class="CONTENT">
		            <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		            <td width="100%" class="CONTENT">&nbsp;</td>
		            <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		        </tr>
			
				<!-- Main Content Row -->
		        <tr class="CONTENT">
	    	        <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		    	    <td height="100%" width="100%" >
		    	    
                        <table width="500">
                        <tr>
                            <td width="150px" valign="top">
                                <span class="VIEWBOXCAPTION">Batch Number:</span><br/>
                                <span class="VIEWBOX" ><asp:DropDownList ID="ddlMailBatchList" runat="server" style="width:150px" /></span>
                            </td>
                            <td>
                                <table class="Button">
				                <tr>
					                <td class="Button">
						                <table cellpadding="0" cellspacing="0" border="0">
						                <tr>
					                        <td></td>
							                <td><asp:LinkButton Text="Generate Export Files" CssClass="er_buttonItem" ID="btnGenerateExportFiles" OnClick="btnGenerateExportFilesClick" runat="server" style="width:250px" /></td>
						                </tr>
						                </table>
					                </td>
				                </tr>
                                </table>
                                <table class="Button">
				                <tr>
					                <td class="Button">
						                <table cellpadding="0" cellspacing="0" border="0">
						                <tr>
							                <td><asp:HyperLink id="HyperLink1" CssClass="er_buttonItemImg" runat="server" BorderStyle="None"></asp:HyperLink></td>
							                <td></td>
							                <td><asp:LinkButton Text="Generate & Send Export Files" CssClass="er_buttonItem" ID="btnGenerateSendExportFiles" OnClick="btnGenerateSendExportFilesClick" OnClientClick="return confirm('Are you sure you want to generate and send the invoice files?');" runat="server" style="width:250px"  /></td>
						                </tr>
						                </table>
					                </td>
				                </tr>
                                </table>
                            </td>
                        </tr>
                        </table>

	    			</td>
	    			<td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		    	</tr>
     
				<tr height=1><td colspan="3" width="1px" class="TABLEBORDERBOTTOM"></td></tr>
     			</table>   <!-- End Table3-->  
        	</td>
			<!-- End Main Content Column -->
        </tr>


        <tr>
        	<td style="width:95%;" valign="top">
                
				<!-- Section Tab Header -->
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
        		<tr class="GridHeader">
		            <td colspan="2">
        		        <table  border="0" cellpadding="0" cellspacing="0">
                	    <tr>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Electronic Invoicing</td>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/panelrightcorner.gif" hspace="0" border="0" align="top"/></td>
	                        <td style="vertical-align:bottom;" colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
	                    </tr>
	                	</table>
            		</td>
        		</tr>
			
				<!-- Blank Row -->	
		        <tr class="CONTENT">
		            <td width="1" class="TABLEBORDERLEFT" ><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		            <td width="100%" class="CONTENT">&nbsp;</td>
		            <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		        </tr>
			
				<!-- Main Content Row -->
		        <tr class="CONTENT">
	    	        <td width="1px" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		    	    <td height="100%" width="100%" >
    
                        <table width="100%">
                        <tr>
							<td width="200px" valign="top">
								<span class="VIEWBOXCAPTION">Include:</span><br/>
								<span class="VIEWBOX" >
							                <select id="ddlInclusionType" name="ddlInclusionType" onchange="toggleInclusion()">
													<option value="">Invoices and Past Due Statements</option>
													<option value="I" selected="selected">Invoices Only</option>
													<option value="P">Past Due Statements Only</option>
							                    </select></span>
			                </td>


                            <td width="150px" valign="top">
                                <span class="VIEWBOXCAPTION">Batch Number:</span><br/>
                                <span class="VIEWBOX" ><asp:DropDownList ID="ddlElectronicBatchList" runat="server"  style="width:300px" /></span>
                            </td>


							<td width="100px" valign="top">
								<span class="VIEWBOXCAPTION">Max Invoices:</span><br/>
								<span class="VIEWBOX" ><input type="text" name="txtMaxInvoices" value="99999" /></span>
							</td>

                            <td>
                                <table class="Button">
				                <tr>
					                <td class="Button">
						                <table cellpadding="0" cellspacing="0" border="0">
						                <tr>
							                <td><asp:HyperLink id="HyperLink2" CssClass="er_buttonItemImg" runat="server" BorderStyle="None"></asp:HyperLink></td>
							                <td></td>
							                <td><asp:LinkButton CssClass="er_buttonItem"  Text="Generate Email/Fax Invoices" ID="btnGenerateEmailFaxInvoices" OnClick="btnGenerateEmailFaxInvoicesClick" runat="server" style="width:250px" /></td>
						                </tr>
						                </table>
					                </td>
				                </tr>
                                </table>
                                <table class="Button">
				                <tr>
					                <td class="Button">
						                <table cellpadding="0" cellspacing="0" border="0">
						                <tr>
							                <td><asp:HyperLink id="HyperLink3" CssClass="er_buttonItemImg" runat="server" BorderStyle="None"></asp:HyperLink></td>
							                <td></td>
							                <td><asp:LinkButton CssClass="er_buttonItem"  Text="Generate & Send Email/Fax Invoices" ID="btnGenerateSendEmailFaxInvoices" OnClick="btnGenerateSendEmailFaxInvoicesClick" OnClientClick="return confirmSendEmails();" runat="server" style="width:250px" /></td>
						                </tr>
						                </table>
					                </td>
				                </tr>
                                </table>
                            </td>
                        </tr>
                        </table>
                    </td>
	    			<td width="1px" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		    	</tr>
     
				<tr height=1><td colspan="3" width="1px" class="TABLEBORDERBOTTOM"></td></tr>
   
     			</table>   <!-- End Table3-->          
            </td>
        </tr>            

        </tbody>			
        </table> <!-- End Table2 -->
	</td>
</tr>
</table> <!-- End Table1 -->


    </form>
</body>
</html>
