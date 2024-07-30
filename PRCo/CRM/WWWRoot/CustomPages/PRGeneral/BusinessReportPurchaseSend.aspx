<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BusinessReportPurchaseSend.aspx.cs" Inherits="PRCo.BBS.CRM.CustomPages.PRGeneral.BusinessReportPurchaseSend" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <asp:TextBox visible="false" id="hidSID" runat="server"/>
    <asp:TextBox visible="false" id="hidUserID" runat="server"/>

<table width="100%" id="Table1">
<tr>
	<td>&nbsp;</td>
	
	<!-- This is the main content column -->
    <td style="width:99%;">
    
        <table width="100%">
        <tr>
            <td>
                <asp:label id="lblMsg" runat="server" Font-Bold="True" ForeColor="Red"></asp:label>
            </td>
        </tr>
        </table>
    
		<table width="100%" border="0">
        <tbody>
        <tr>
        	<td style="width:90%;" valign="top">
   				<table width="100%" border="0" cellpadding="0" cellspacing="0" id="Table3">
		        <tr>
        		    <td class="ROWGap" colspan="6">&nbsp;</td>
		        </tr>
				
				<!-- Section Tab Header -->
        		<tr>
		            <td colspan="2">
        		        <table  border="0" cellpadding="0" cellspacing="0">
                	    <tr>
	                        <td valign="bottom"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Email Business Report</td>
	                        <td valign="bottom"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/panerightcorner.gif" hspace="0" border="0" align="top"/></td>
	                        <td style=" vertical-align:bottom; " colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
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
		    	    
                        <table width="100%">
                        <tr>
                            <td width="150px" valign="top">
                                <span class="VIEWBOXCAPTION">Email Address:</span><br/>
                                <span class="VIEWBOX" ><asp:TextBox ID="EmailAddress" runat="server" style="width:200px" /></span>
                            </td>
                            <td>
                                <asp:Button Text="Send" ID="btnGenerateExportFiles" OnClick="btnSendClick" OnClientClick="return confirm('Are you sure you want to send this Business Report?');" runat="server" style="width:100px" /><br />
                                <asp:Button Text="Cancel" ID="btnGenerateSendExportFiles" OnClick="btnCancelClick" runat="server" style="width:100px" />
                            </td>
                        </tr>
                        </table>

	    			</td>
	    			<td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		    	</tr>
     
				<tr height=1><td colspan="3" width="1px" class="TABLEBORDERBOTTOM"></td></tr>
        		<tr>
          		  <td class="ROWGap">&nbsp;</td>
        		</tr>
    
     			</table>   <!-- End Table3-->  
        	</td>
			<!-- End Main Content Column -->
        </tr>

        </tbody>			
        </table> <!-- End Table2 -->
	</td>
</tr>
</table> <!-- End Table1 -->
    </form>
</body>
</html>
