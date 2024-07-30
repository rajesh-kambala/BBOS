<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PRCompanySocialMediaEdit.aspx.cs" Inherits="PRCo.BBS.CRM.PRCompanySocialMediaEdit" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <asp:Literal ID="Literal1" Visible="false" runat="server">
        <link href="../../prco.css" rel="stylesheet" type="text/css" />
        <link href="../../eware.css" rel="stylesheet" type="text/css" />
    </asp:Literal>


    <script type="text/javascript">
        function save() {

            var errMsg = "";
            var textBoxes = document.getElementsByTagName("input");
            for (i = 0; i < textBoxes.length; i++) {
                if (textBoxes[i].id.indexOf("txtSMURL_") == 0) {
                    var code = textBoxes[i].id.substring(9, textBoxes[i].id.length);
                    errMsg += validateSocialMediaURL(code)
                }
            }

            if (errMsg.length > 0) {
                alert("The following errors have occurred.\n\n" + errMsg);
                return false;
            }

            return true;
        }


        function validateSocialMediaURL(code) {

            var domain = document.getElementById("hdnSMDomain_" + code).value;
            var url = document.getElementById("txtSMURL_" + code).value;

            if (url.length == 0) {
                return "";
            }

            if (url.toLowerCase().indexOf("http://") == 0) {
                url = url.substring(7, url.length);
            } else if (url.toLowerCase().indexOf("https://") == 0) {
                url = url.substring(8, url.length);
            }


            var posSlash = url.indexOf("/");
            var posDomain = url.indexOf(domain);

            if ((posDomain == -1) ||
            (posDomain > posSlash)) {

                var label = document.getElementById("tdSM_" + code).innerText;
                return " - An invalid social media URL has been specified for the " + label + "\n";
            }

            return "";
        }

        function redirect() {
            window.top.location.href = document.getElementById("ReturnURL").value;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:TextBox visible="false" id="hidSID" runat="server"/>
    <asp:TextBox visible="false" id="hidUserID" runat="server"/>
    <asp:TextBox visible="false" id="hidCompanyID" runat="server"/>
    <asp:HiddenField ID="ReturnURL" runat="server" />

    <asp:Repeater ID="repSocialMediaDomains" runat="server">
        <ItemTemplate>
            <input type="hidden" id="hdnSMDomain_<%# Eval("capt_code") %>" value="<%# Eval("capt_US") %>" />
        </ItemTemplate>
    </asp:Repeater>


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
        	<td style="width:95%;" valign="top">

   				<table width="100%" border="0" cellpadding="0" cellspacing="0">
        		<tr class="GridHeader">
		            <td colspan="2">
        		        <table  border="0" cellpadding="0" cellspacing="0">
                	    <tr>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Edit Social Media</td>
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

                    <table>
                    <asp:Repeater ID="repSocialMedia" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td class="VIEWBOXCAPTION" id="tdSM_<%# Eval("capt_Code") %>"><%# Eval("capt_US") %>:</td>
                            <td class="VIEWBOXCAPTION"><input type="text" name="txtSMURL_<%# Eval("capt_Code") %>" id="txtSMURL_<%# Eval("capt_Code") %>" value="<%# Eval("prsm_URL") %>" maxlength="500" size="60" onchange="validateSocialMediaURL('<%# Eval("capt_Code") %>');"/>
                                <input type="hidden" name="hdnSMID_<%# Eval("capt_Code") %>" id="hdnSMID_<%# Eval("capt_Code") %>" value="<%# Eval("prsm_SocialMediaID") %>" />
                            </td>
                        </tr>
                    </ItemTemplate>                        
                    </asp:Repeater>
                    </table>
    
	    			</td>
	    			<td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		    	</tr>
     
				<tr height=1><td colspan="3" width="1px" class="TABLEBORDERBOTTOM"></td></tr>
  
     			</table>   <!-- End Table3-->  
        	</td>
			<!-- End Main Content Column -->
			
			<!-- This is the button column -->
			<td valign="top" width="5%">
				<table class="Button">
				<tr>
					<td class="Button">
						<table cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td><asp:HyperLink ID="hlCancelImg" BorderStyle="None" ImageAlign="Middle" CssClass="er_buttonItemImg" Target="_parent" runat="server" /></td>
							<td>&nbsp;</td>
							<td><asp:HyperLink ID="hlCancel" Text="Cancel" CssClass="er_buttonItem" Target="_parent" runat="server" /></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td class="Button">
						<table cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td><asp:HyperLink ID="imgbtnSave" CssClass="er_buttonItemImg" OnClick="btnSaveOnClick" OnClientClick="return save();" runat="server" BorderStyle="None" ImageAlign="Middle" /></td>
							<td>&nbsp;</td>
							<td><asp:LinkButton ID="btnSave" Text="Save" OnClientClick="return save();" CssClass="er_buttonItem" OnClick="btnSaveOnClick" runat="server" /></td>
						</tr>
						</table>
					</td>
				</tr>
				

				</table>
			</td>	
			<!-- End button column -->
			
        </tr>


        </tbody>			
        </table> <!-- End Table2 -->
	</td>
</tr>
</table> <!-- End Table1 -->


</form>
</body>
</html>
