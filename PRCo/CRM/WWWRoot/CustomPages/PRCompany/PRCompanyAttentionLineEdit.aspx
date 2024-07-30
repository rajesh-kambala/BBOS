<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeBehind="PRCompanyAttentionLineEdit.aspx.cs" Inherits="PRCo.BBS.CRM.PRCompanyAttentionLineEdit" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title></title>
    
    <asp:Literal ID="Literal1" Visible="false" runat="server">
        <link href="../../prco.css" rel="stylesheet" type="text/css" />
        <link href="/crm/Themes/Kendo/kendo.default.min.css" rel="stylesheet" />
        <link href="/crm/Themes/Kendo/kendo.common.min.css" rel="stylesheet"/>
        <link href="/crm/Themes/ergonomic.css?83568" rel="stylesheet"/>

    </asp:Literal>
    
    <script type="text/javascript" src="PRCompanyAttentionLineEdit.js"></script>	    
    <script type="text/javascript">
        function redirect() {
            window.top.location.href = document.getElementById("ReturnURL").value;
        }
    </script>
</head>
<body onload="initControls();">
    <form id="form1" runat="server">
    <asp:TextBox visible="false" id="hidSID" runat="server"/>
    <asp:TextBox visible="false" id="hidUserID" runat="server"/>
    <asp:TextBox visible="false" id="hidAttenionLineID" runat="server"/>


    <asp:HiddenField ID="ReturnURL" runat="server" />

    <asp:HiddenField ID="hidAddressee" runat="server" />
    <asp:HiddenField ID="hidDelivery" runat="server" />
    <asp:HiddenField ID="hidCompanyID" runat="server" />
    <asp:HiddenField ID="hidPersonID" runat="server" />

    <asp:HiddenField ID="hidAddressID" runat="server" />
    <asp:HiddenField ID="hidEmailID" runat="server" />
    <asp:HiddenField ID="hidPhoneID" runat="server" />
    <asp:HiddenField ID="hidCustom" runat="server" />
    <asp:HiddenField ID="hidOldDelivery" runat="server" />
    <asp:HiddenField ID="hidOldAddressee" runat="server" />
    <asp:HiddenField ID="hidUpdateOthers" runat="server" />

    <asp:HiddenField ID="hidAddressEnabled" Value="true" runat="server" />
    <asp:HiddenField ID="hidFaxEnabled" Value="true" runat="server" />
    <asp:HiddenField ID="hidEmailEnabled" Value="true" runat="server" />
    <asp:HiddenField ID="hidBBOSEnabled" Value="true" runat="server" />
    <asp:HiddenField ID="hidSkipAddresseeInit" Value="false" runat="server" />

    <asp:ScriptManager ID="ScriptManager1" EnablePartialRendering="true" EnableScriptGlobalization="true"  runat="server" >
	    <Services>
            <ajax:ServiceReference Path="/CRM/CustomPages/AJAXHelper.asmx" />
        </Services>
    </asp:ScriptManager>


    
    
<table width="100%" id="Table1">
<tr>
	<td>&nbsp;</td>
	
	<!-- This is the main content column -->
    <td style="width:99%;">
    
        <table width="100%">
        <tr>
            <td>
                <asp:label id="lblMsg" runat="server" Font-Bold="True"></asp:label>
            </td>
        </tr>
        </table>
    
		<table width="100%" border="0">
        <tbody>
        <tr>
        	<td style="width:90%;" valign="top">
   				<table width="100%" border="0" cellpadding="0" cellspacing="0" >
				
				<!-- Section Tab Header -->
        		<tr class="GridHeader">
		            <td colspan="2">
        		        <table  border="0" cellpadding="0" cellspacing="0">
                	    <tr>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Edit Company Attention Line</td>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/panelrightcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="vertical-align:bottom; " colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
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
    

                    <table width="100%">
                    <tr>
                        <td  valign="top" width="50%">
                            <span class="VIEWBOXCAPTION">Item:</span><br />
                            <asp:label id="lblItem" class="VIEWBOX" runat="server"  />
                        </td>                            
                        <td  valign="top" width="50%" >
                            <table cellpadding="0" cellspacing="0" border="0"><tr><td>
                                <asp:CheckBox ID="cbIncludeWTI" visible="false" runat="server" Text="Include Wire Transfer Instructions" CssClass="VIEWBOXCAPTION" />
                            </td></tr></table> 
                        </td>                            
                    </tr>
                    
                    <tr>
                        <td>
                            <table cellpadding="0" cellspacing="0" border="0"><tr><td>
                                <asp:CheckBox ID="cbDisabled" runat="server" Text="Disabled" CssClass="VIEWBOXCAPTION" />
                            </td></tr></table>    
                        </td>
                    </tr>
                    
                    
                    <tr>
                        <td  valign="top">
                            <span class="VIEWBOXCAPTION">Addressee:</span><br />
                            <table>
                                <tr><td valign="top"><input type="radio" id="rbAddresseePerson" checked onclick="toggleAddressee();" name="rbAddressee" /></td>
                                    <td><span class="VIEWBOXCAPTION">Person:</span><br />
                                        <asp:DropDownList ID="ddlPerson" runat="server" />
                                    </td>                                
                                </tr>
                                <tr><td valign="top"><input type="radio" id="rbAddresseeCustom" onclick="toggleAddressee();" name="rbAddressee" /></td>
                                    <td><span class="VIEWBOXCAPTION">Custom:</span><br />
                                        <asp:TextBox ID="txtCustomLine" Columns="40" MaxLength="100" runat="server" />
                                    </td>                                
                                </tr>                            
                            </table>
                        </td>
                        
                        <td>
                           <span class="VIEWBOXCAPTION">Delivery:</span><br />
                            <table>
                                <tr>
                                    <td valign="top"><input type="radio" id="rbDeliveryAddress" onclick="toggleDelivery();" value="address" name="rbDelivery" /></td>
                                    <td><span class="VIEWBOXCAPTION">Address:</span><br />
                                            <asp:DropDownList ID="ddlAddress" runat="server" />
                                    </td>
                                </tr>

                                <tr>
                                    <td valign="top"><input type="radio" id="rbDeliveryFax" onclick="toggleDelivery();" value="fax" name="rbDelivery" /></td>
                                    <td><span class="VIEWBOXCAPTION"><asp:Literal ID="lblPhone" runat="server">Fax:</asp:Literal></span><br />
                                        <asp:DropDownList ID="ddlFax" runat="server" />
                                        <cc1:CascadingDropDown ID="ccFax" runat="server"
                                         BehaviorID="ccFax"
                                         TargetControlID="ddlFax"
                                         ParentControlID="ddlPerson"
                                         Category="Fax"
                                         UseContextKey="true"
                                         ServiceMethod="GetAttentionLinePhone" />
                                    </td>
                                </tr>


                                <tr>
                                    <td valign="top"><input type="radio" id="rbDeliveryEmail" onclick="toggleDelivery();" value="email" name="rbDelivery" /></td>
                                    <td><span class="VIEWBOXCAPTION">Email:</span><br />
                                        <asp:DropDownList ID="ddlEmail" runat="server" />
                                        <cc1:CascadingDropDown ID="ccEmail" runat="server"
                                         BehaviorID="ccEmail"
                                         TargetControlID="ddlEmail"
                                         ParentControlID="ddlPerson"
                                         Category="Email"
                                         UseContextKey="true"
                                         ServiceMethod="GetAttentionLineEmail" />                                    
                                    </td>
                                </tr>
                                
                                <tr>
                                    <td valign="top"><input type="radio" id="rbDeliveryBBOS" onclick="toggleDelivery();" value="BBOS" name="rbDelivery" /></td>
                                    <td><span class="VIEWBOXCAPTION">BBOS Only:</span>
                                    </td>
                                </tr>                                
                                
                           </table>
                        </td>
                    </tr>
                    
                    <tr><td>&nbsp;</td></tr>
                    <tr>
                        <td>
                            <span class="VIEWBOXCAPTION">Last Updated Date:</span><br />
                            <asp:Label ID="lblUpdatedDate" class="VIEWBOX" runat="server" />
                        </td>
                    
                        <td>
                            <span class="VIEWBOXCAPTION">Last Updated By:</span><br />
                            <asp:Label ID="lblUpdatedBy" class="VIEWBOX" runat="server" />
                        </td>
                    </tr>
                    
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
						<table cellpadding="0" cellspacing="0" border="0" id="tblSaveButton" runat="server">
						<tr>
							<td><asp:HyperLink ID="imgbtnSave" CssClass="er_buttonItemImg" OnClick="btnSaveOnClick"  OnClientClick="return onSave();" runat="server" BorderStyle="None" ImageAlign="Middle" /></td>
							<td>&nbsp;</td>
							<td><asp:LinkButton ID="btnSave" Text="Save" CssClass="er_buttonItem" OnClick="btnSaveOnClick" OnClientClick="return onSave();" runat="server" /></td>
						</tr>
						</table>
					</td>
				</tr>
				
				<tr>
					<td class="Button">
						<table cellpadding="0" cellspacing="0" border="0" runat="server" id="tblDeleteButton" visible="false">
						<tr>
							<td><asp:HyperLink ID="imgbtnDelete" CssClass="er_buttonItemImg" OnClick="btnDeleteOnClick"  OnClientClick="return onDelete();" runat="server" BorderStyle="None" ImageAlign="Middle" /></td>
							<td>&nbsp;</td>
							<td><asp:LinkButton ID="btnDelete" Text="Delete" CssClass="er_buttonItem" OnClick="btnDeleteOnClick" OnClientClick="return onDelete();" runat="server" /></td>
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
			