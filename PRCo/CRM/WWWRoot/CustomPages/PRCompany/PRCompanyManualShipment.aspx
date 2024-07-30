<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PRCompanyManualShipment.aspx.cs" Inherits="PRCo.BBS.CRM.PRCompanyManualShipment" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <asp:Literal ID="Literal1" Visible="false" runat="server">
        <link href="../../prco.css" rel="stylesheet" type="text/css" />
        <link href="../../eware.css" rel="stylesheet" type="text/css" />
    </asp:Literal>

    <script type="text/javascript">
        var btnSaveClick = false;

        function onSave() {

            if (btnSaveClick == true) {
                return;
            }
            btnSaveClick = true;

            var bItemSelected = false;
            var bAttnSelected = false;

            var controls = document.getElementsByTagName("input");

            for (i = 0; i < controls.length; i++) {
                if (controls[i].checked) {

                    if (controls[i].type == "checkbox") {
                        bItemSelected = true;
                    }

                    if (controls[i].type == "radio") {
                        bAttnSelected = true;
                    }

                }
            }

            if (!bItemSelected) {

                alert("An item must must be selected.");
                btnSaveClick = false; 
                return false;
            }

            if (!bAttnSelected) {
                alert("An attention line must must be selected.");
                btnSaveClick = false; 
                return false;
            }

            return true;
        }

        function attnLineClick() {
            var rbs = document.getElementsByName("rbAddresses");
            uncheckAll(rbs);
            document.getElementById("txtAddressee").disabled = true;
        }

        function addressClick() {
            var rbs = document.getElementsByName("rbAttentionLine");
            uncheckAll(rbs);
            document.getElementById("txtAddressee").disabled = false;
        }

        function uncheckAll(listControl) {
            for (var i = 0; i < listControl.length; i++) {
                listControl[i].checked = false;
            }
        }

        function success() {
            alert("The shipment has been successfully created and placed in the queue.");
            window.top.location.href = "PRCompanyAttentionLine.asp?Key0=1&Key1=" + document.getElementById("hidCompanyID").value + "&SID=" + document.getElementById("hidSID").value + "&T=Company&Capt=Contact+Info";
        }

    </script>

</head>
<body>
    <form id="form1" runat="server">
    <div>
    <asp:HiddenField id="hidSID" runat="server"/>
    <asp:HiddenField id="hidUserID" runat="server"/>    
    <asp:HiddenField ID="hidCompanyID" runat="server" />

<table width="100%" id="Table1">
<tr>
	<td>&nbsp;</td>
	
	<!-- This is the main content column -->
    <td style="width:99%;">
    
        <table width="100%">
        <tr>
            <td>
                <asp:label id="lblMsg" runat="server"  Font-Bold="True" ForeColor="Red" />
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
	                        <td valign="bottom"><img alt="" src="/<%= _szAppName%>/img/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Create Manual Shipment</td>
	                        <td valign="bottom"><img alt="" src="/<%= _szAppName%>/img/backgrounds/panerightcorner.gif" hspace="0" border="0" align="top"/></td>
	                        <td style=" vertical-align:bottom; " colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
	                    </tr>
	                	</table>
            		</td>
        		</tr>
			
				<!-- Blank Row -->	
		        <tr class="CONTENT">
		            <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		            <td width="100%" class="CONTENT">&nbsp;</td>
		            <td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		        </tr>
			
				<!-- Main Content Row -->
		        <tr class="CONTENT">
	    	        <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		    	    <td height="100%" width="100%" >
    
                    <div style="text-align:center;padding-bottom:10px;" class="VIEWBOXCAPTION">
                        To create a manual shipment, either select an existing attention line or select a company address.
                    </div>

                    <table width="100%">
                    <tr>
                        <td  valign="top" width="33%">
                            <span class="VIEWBOXCAPTION">Items:</span><br />
                            <span class="EDIT">
                            <asp:CheckBoxList ID="cblItems" runat="server" />
                            </span>
                        </td>                            

                        <td  valign="top" width="33%" rowspan="3">
                            <span class="VIEWBOXCAPTION">Attention Lines:</span><br />
                            <span class="EDIT">
                            <asp:RadioButtonList ID="rbAttentionLine" RepeatColumns="2" Width="100%" runat="server" onclick="attnLineClick()" />
                            </span>
                        </td>                            

                        <td  valign="top" width="33%" rowspan="2">
                            <span class="VIEWBOXCAPTION">Company Addresses:</span><br />
                            <span class="EDIT">
                            <b>Addressee:</b> <asp:TextBox ID="txtAddressee" runat="server" />
                            <asp:RadioButtonList ID="rbAddresses" runat="server" onclick="addressClick()" />
                            </span>
                        </td>                            
                    </tr>

                    <tr>
                        <td  valign="top" >
                            <span class="VIEWBOXCAPTION">Mail Room Comments:</span><br />
                            <span class="EDIT"><asp:TextBox ID="txtComments" cols="25" Rows="5" TextMode="MultiLine" runat="server" /></span>
                        </td>                     
                    </tr>
                    <tr><td>&nbsp;</td></tr>
                    </table>

   
	    			</td>
	    			<td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		    	</tr>
     
                <tr height=1><td colspan="3" width="1px" class="TABLEBORDERBOTTOM"></td></tr>


        		<tr>
          		  <td class="ROWGap">&nbsp;</td>
        		</tr>
    
     			</table>   <!-- End Table3-->  
        	</td>
			<!-- End Main Content Column -->
			
			<!-- This is the button column -->
			<td valign="top" width="5%">
				<table>
				<tr>
					<td >
						<table cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td><asp:HyperLink ID="hlContinueImg" BorderStyle="None" ImageAlign="Middle" CssClass="ButtonItem" runat="server" target="_parent" /></td>
							<td>&nbsp;</td>
							<td><asp:HyperLink ID="hlContinue" Text="Continue" CssClass="ButtonItem" runat="server" target="_parent" /></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td >
						<table cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td><asp:ImageButton ID="imgbtnSave" CssClass="ButtonItem" OnClick="btnSaveOnClick"  OnClientClick="return onSave();" runat="server" BorderStyle="None" ImageAlign="Middle" /></td>
							<td>&nbsp;</td>
							<td><asp:LinkButton ID="btnSave" Text="Save" CssClass="ButtonItem" OnClick="btnSaveOnClick" OnClientClick="return onSave();" runat="server" /></td>
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



    </div>
    </form>
</body>
</html>
