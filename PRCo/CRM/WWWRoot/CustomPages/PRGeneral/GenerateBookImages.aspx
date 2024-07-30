<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GenerateBookImages.aspx.cs" Inherits="PRCo.BBS.CRM.GenerateBookImages" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Generate Book Images</title>
    <asp:Literal ID="Literal1" Visible="false" runat="server">
        <!-- 
            This is to handle the CSS warnings that Visual Studio flags.  We could just turn off CSS
            validation, but I think it's better to know when we're referencing invalid classes.
        -->            
        <link href="../../prco.css" rel="stylesheet" type="text/css" />
        <link href="../../eware.css" rel="stylesheet" type="text/css" />
    </asp:Literal>

    <script type="text/javascript">
        function CheckAll(szPrefix, bChecked) {
            var oCheckboxes = document.body.getElementsByTagName("INPUT");
            for (var i = 0; i < oCheckboxes.length; i++) {
                if ((oCheckboxes[i].type == "checkbox") &&
		            (oCheckboxes[i].name.indexOf(szPrefix) == 0)) {
                    if (oCheckboxes[i].disabled == false) {
                        oCheckboxes[i].checked = bChecked;
                    }
                }
            }
        }

        function confirmAutoRemoveNumerals() {
            return confirm("This will remove all interim rating numerals on listed companies.  Are you sure you want to continue?");
        }
    </script>

</head>
<body>
    <form id="form1" runat="server">
    
    
    <asp:TextBox visible="false" id="hidSID" runat="server"/>
    <asp:TextBox visible="false" id="hidUserID" runat="server"/>    
    
<table width="100%" style="margin-top:5px;" cols="3">
<tr>
	<td style="width:15px;"></td>
    <td style="vertical-align:top;">
        <table width="100%">
        <tr>
            <td>
                <asp:label id="lblMsg" runat="server" Font-Bold="True"></asp:label>
            </td>
        </tr>
        </table>
    
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tbody>
        <tr>
            <td style="width:15px;"></td>
        	<td style="width:95%;" valign="top">
            
   				<table width="100%" border="0" cellpadding="0" cellspacing="0" id="Table2">
        		<tr class="GridHeader">
		            <td colspan="2">
        		        <table  border="0" cellpadding="0" cellspacing="0">
                	    <tr>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Auto Remove Numerals</td>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/panelrightcorner.gif" hspace="0" border="0" align="top"/></td>
	                        <td style="vertical-align:bottom;" colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
	                    </tr>
	                	</table>
            		</td>
        		</tr>
		
		
				<!-- Main Content Row -->
		        <tr class="CONTENT">
	    	        <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		    	    <td height="100%" width="100%" >

                    <table>
                    <tr>
                        <td  valign="top"  width="300px">
                            <span class="VIEWBOXCAPTION">Last Execution Date:</span><br>
                            <span class="VIEWBOX"><asp:Literal ID="litLastExecutionDate" runat="server" /></span>
                        </td>
                        <td  valign="top"  width="300px">
                            <span class="VIEWBOXCAPTION">Last Excecuted By:</span><br>
                            <span class="VIEWBOX"><asp:Literal ID="litLastExecutedBy" runat="server" /></span>
                        </td>
                    </tr>		    	    
                    </table>

	    			</td>
	    			<td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		    	</tr>
     
                <tr height="1"><td colspan="3" width="1px" class="TABLEBORDERBOTTOM"></td></tr>
        		<tr>
          		  <td class="ROWGap">&nbsp;</td>
        		</tr>
    
     			</table>   <!-- End Table3-->  



   				<table width="100%" border="0" cellpadding="0" cellspacing="0" id="Table3">

        		<tr class="GridHeader">
		            <td colspan="2">
        		        <table  border="0" cellpadding="0" cellspacing="0">
                	    <tr>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Generate Book Images</td>
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
		    	    <td width="100%" >
		    	    <span class="VIEWBOX" >		    	    
		    	    
                    <asp:Panel ID="pnlSelect" HorizontalAlign="Center" runat="server">
                    [ <a href="javascript:CheckAll('cblBookImages', true);">Select All</a> | <a href="javascript:CheckAll('cblBookImages', false);">Deselect All</a> ]
                    </asp:Panel>
		    	    

		    	    <asp:CheckBoxList ID="cblBookImages" RepeatColumns="3" RepeatDirection="Horizontal" Width="100%" runat="server" />
		    	    </span>
		    	    
		    	    
<pre>
<asp:Label id="lblOutput" runat="server" />
</pre>
		    	    
		    	    
	    			</td>
	    			<td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		    	</tr>
     
                <tr height="1"><td colspan="3" width="1px" class="TABLEBORDERBOTTOM"></td></tr>
        		<tr>
          		  <td class="ROWGap">&nbsp;</td>
        		</tr>
    
     			</table>   <!-- End Table3-->  





        	</td>
			<!-- End Main Content Column -->
			
			<!-- This is the button column -->
		<td valign="top" width="5%" style="right:130px;padding-top:87.25px;">
				<table class="Button">
				<tr>
					<td class="Button">
						<table cellpadding="0" cellspacing="0" border="0">
						<tr id="trRemoveInterimNumerals" runat="server">
							<td style="padding-bottom:15px;"><asp:ImageButton ID="imgbtnRemoveInterimNumerals" OnClientClick="return confirmAutoRemoveNumerals();" CssClass="er_buttonItemImg" OnClick="btnRemoveInterimNumeralsClick" runat="server" BorderStyle="None" ImageAlign="Middle" /></td>
							<td style="padding-bottom:15px;">&nbsp;</td>
							<td style="padding-bottom:15px;"><asp:LinkButton ID="btnRemoveInterimNumerals" OnClientClick="return confirmAutoRemoveNumerals();" Text="Remove Interim Numerals" CssClass="er_buttonItem" OnClick="btnRemoveInterimNumeralsClick" runat="server" /></td>
						</tr>
						<tr>
							<td><asp:ImageButton ID="imgbtnGenerate" CssClass="er_buttonItemImg" OnClick="btnGenerateBookImages" runat="server" BorderStyle="None" ImageAlign="Middle" /></td>
							<td>&nbsp;</td>
							<td><asp:LinkButton ID="btnGenerate" Text="Generate Book Images" CssClass="er_buttonItem" OnClick="btnGenerateBookImages" runat="server" /></td>
						</tr>

						</table>
					</td>
				</tr>
				</table>
			</td>	
        </tr>		    	        

        <tr>
            <td style="width:15px;"></td>
        	<td style="width:95%;" valign="top">

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
