<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GenerateAddressLists.aspx.cs" Inherits="PRCo.BBS.CRM.CustomPages.PRGeneral.GenerateAddressLists" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title></title>

    <asp:Literal ID="Literal1" Visible="false" runat="server">
        <link href="../../prco.css" rel="stylesheet" type="text/css" />
        <link href="../../eware.css" rel="stylesheet" type="text/css" />
    </asp:Literal>    
    
</head>
<body>
    <form id="form1" runat="server">
    <asp:TextBox visible="false" id="hidSID" runat="server"/>
    <asp:TextBox visible="false" id="hidUserID" runat="server"/>      
    
    
<table width="100%" style="margin-top:5px;" cols="3">
<tr>
	<td style="width:15px;"></td>
	
	<!-- This is the main content column -->
    <td style="vertical-align:top;">
    
        <table width="100%">
        <tr>
            <td>
                <asp:label id="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" />
            </td>
        </tr>
        </table>
    
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tbody>
        <tr>
        
        	<td style="width:95%;" valign="top">
   				<table width="100%" border="0" cellpadding="0" cellspacing="0">
				
				<!-- Section Tab Header -->
        		<tr class="GridHeader">
		            <td colspan="2">
        		        <table border="0" cellpadding="0" cellspacing="0" ID="Table6">
                	    <tr>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Book Address Lists</td>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/panelrightcorner.gif" hspace="0" border="0" align="top"/></td>
	                        <td style="vertical-align:bottom;" colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
	                    </tr>
	                	</table>
            		</td>
            		
        		</tr>
			
				<!-- Blank Row -->	
		        <tr class="CONTENT">
		            <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" HSPACE="0" BORDER="0" ALIGN="top"/></td>
		            <td width="100%" class="CONTENT">&nbsp;</td>
		            <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" HSPACE="0" BORDER="0" ALIGN="top"/></td>
		        </tr>
			
				<!-- Main Content Row -->
		        <tr class="CONTENT">
	    	        <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" HSPACE="0" BORDER="0" ALIGN="top"/></td>
		    	    <td HEIGHT="100%" width="100%" class="VIEWBOX">

                    <table>
                    <tr>
                        <td>
                            <asp:DropDownList ID="ddlBookType" runat="server" />
                        </td>
                        <td>
                            <asp:Button ID="btnGeneratePreviewFiles"   Width="225px" OnClick="btnGeneratePreviewFilesOnClick" Text="Generate Address List for Review" runat="server" />
                        </td>

                    </tr>

                    <tr>
                        <td></td>
                        <td>
                            <asp:Button ID="btnGenerateExceptionFiles" Width="225px" OnClick="btnGenerateExceptionFilesOnClick" Text="Generate Exception Lists" runat="server" />
                        </td>
                    </tr>                        

                    <tr>
                        <td></td>
                        <td>
                            <asp:Button ID="btnGenerateDeliveryFiles"  Width="225px" OnClick="btnGenerateDeliveryFilesOnClick" OnClientClick="return confirm('Are you sure you want to generate the book shipment files?  This will create Shipment Log entries.');" Text="Generate Address List for Shipment" runat="server" />
                        </td>

                    </tr>

                    </table>



	    			</td>
	    			<td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" HSPACE="0" BORDER="0" ALIGN="top"/></td>
		    	</tr>
                <tr height=1><td colspan="3" width="1px" class="TABLEBORDERBOTTOM"></td></tr>
     			</table>   <!-- End Table3-->  
        	</td>        
        </tr>


        <tr>
        	<td style="width:90%;" valign="top">
   				<table width="100%" border="0" cellpadding="0" cellspacing="0" RULES="none" ID="Table3">
				
				<!-- Section Tab Header -->
        		<tr class="GridHeader">
		            <td colspan="2">
        		        <table border="0" cellpadding="0" cellspacing="0" ID="Table5">
                	    <tr>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Blueprints Address Lists</td>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/panelrightcorner.gif" hspace="0" border="0" align="top"/></td>
	                        <td style="vertical-align:bottom;" colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
	                    </tr>
	                	</table>
            		</td>
        		</tr>
			
				<!-- Blank Row -->	
		        <tr class="CONTENT">
		            <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" HSPACE="0" BORDER="0" ALIGN="top"/></td>
		            <td width="100%" class="CONTENT">&nbsp;</td>
		            <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" HSPACE="0" BORDER="0" ALIGN="top"/></td>
		        </tr>
			
				<!-- Main Content Row -->
		        <tr class="CONTENT">
	    	        <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" HSPACE="0" BORDER="0" ALIGN="top"/></td>
		    	    <td HEIGHT="100%" width="100%" class="VIEWBOX">


                    <table>
                    <tr>
                       <td>
                            <asp:CheckBox ID="cbIncludeInternational" Text="Include International Addresses" runat="server" />
                        </td>    
                        <td>
                            <asp:Button ID="Button1"   Width="225px" OnClick="btnGeneratePreviewBPrintFilesOnClick" Text="Generate Address List for Review" runat="server" />
                        </td>

                    </tr>

                    <tr>
                        <td></td>
                        <td>
                            <asp:Button ID="Button2" Width="225px" OnClick="btnGenerateBPExceptionFilesOnClick" Text="Generate Exception Lists" runat="server" />
                        </td>
                    </tr>                        

                    <tr>
                        <td></td>
                        <td>
                            <asp:Button ID="Button3"  Width="225px" OnClick="btnGenerateBPrintFilesOnClick" OnClientClick="return confirm('Are you sure you want to generate the Blueprints shipment file?  This will create Shipment Log entries.');" Text="Generate Address List for Shipment" runat="server" />
                        </td>

                    </tr>

                    </table>


                    
	    			</td>
	    			<td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" HSPACE="0" BORDER="0" ALIGN="top"/></td>
		    	</tr>
     
                <tr height=1><td colspan="3" width="1px" class="TABLEBORDERBOTTOM"></td></tr>
     			</table>   <!-- End Table3-->  
        	</td>
			<!-- End Main Content Column -->
        </tr>



       <tr>
        	<td style="width:90%;" valign="top">
   				<table width="100%" border="0" cellpadding="0" cellspacing="0" RULES="none" ID="KYCG">
			
				<!-- Section Tab Header -->
        		<tr class="GridHeader">
		            <td colspan="2">
        		        <table border="0" cellpadding="0" cellspacing="0" ID="Table5">
                	    <tr>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">KYC Guide</td>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/panelrightcorner.gif" hspace="0" border="0" align="top"/></td>
	                        <td style="vertical-align:bottom;" colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
	                    </tr>
	                	</table>
            		</td>
        		</tr>
			
				<!-- Blank Row -->	
		        <tr class="CONTENT">
		            <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" HSPACE="0" BORDER="0" ALIGN="top"/></td>
		            <td width="100%" class="CONTENT">&nbsp;</td>
		            <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" HSPACE="0" BORDER="0" ALIGN="top"/></td>
		        </tr>
			
				<!-- Main Content Row -->
		        <tr class="CONTENT">
	    	        <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" HSPACE="0" BORDER="0" ALIGN="top"/></td>
		    	    <td HEIGHT="100%" width="100%" class="VIEWBOX">


                    <table>
                    <tr>
                       <td>
                            <asp:CheckBox ID="cbKYCGIncludeInternationalAddresses" Text="Include International Addresses" runat="server" />
                        </td>    
                        <td>
                            <asp:Button ID="Button4"   Width="225px" OnClick="btnGeneratePreviewKYCGFilesOnClick" Text="Generate Address List for Review" runat="server" />
                        </td>

                    </tr>

                    <tr>
                        <td></td>
                        <td>
                            <asp:Button ID="Button5" Width="225px" OnClick="btnGenerateKYCGExceptionFilesOnClick" Text="Generate Exception Lists" runat="server" />
                        </td>
                    </tr>                        

                    <tr>
                        <td></td>
                        <td>
                            <asp:Button ID="Button6"  Width="225px" OnClick="btnGenerateKYCGFilesOnClick" OnClientClick="return confirm('Are you sure you want to generate the KYC Guide shipment file?  This will create Shipment Log entries.');" Text="Generate Address List for Shipment" runat="server" />
                        </td>

                    </tr>

                    </table>


                    
	    			</td>
	    			<td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" HSPACE="0" BORDER="0" ALIGN="top"/></td>
		    	</tr>
     
                <tr height=1><td colspan="3" width="1px" class="TABLEBORDERBOTTOM"></td></tr>
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
