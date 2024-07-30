<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeBehind="PRCompanySendRequests.aspx.cs" Inherits="PRCo.BBS.CRM.PRCompanySendRequests" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <asp:TextBox visible="false" id="hidSID" runat="server"/>
    <asp:TextBox visible="false" id="hidUserID" runat="server"/>
    <asp:TextBox visible="false" id="hidCompanyID" runat="server"/>
    <asp:TextBox visible="false" id="hidLanguage" runat="server"/>
    <asp:TextBox visible="false" id="hidIndustryType" runat="server"/>

<table width="100%" style="margin-top:5px;" cols="3">
<tr>
	<td style="width:15px;"></td>
    <td style="vertical-align:top;">
    
        <table width="100%">
        <tr id="trMsg" Visible="false" runat="server">
            <td>
                <asp:label id="lblMsg" runat="server" Font-Bold="True"></asp:label>
            </td>
        </tr>

        <tr id="lblSpanish" Visible="false" runat="server">
            <td>
                <asp:label runat="server" Font-Bold="True">This company's langauge is set to Spanish, so the Spanish version of the forms will be sent.</asp:label>
            </td>
        </tr>

        </table>
    
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tbody>
        <tr>
            <td style="width:15px;"></td>
        	<td style="width:95%;" valign="top">

   				<table width="100%" border="0" cellpadding="0" cellspacing="0">
        		<tr class="GridHeader">
		            <td colspan="2">
        		        <table  border="0" cellpadding="0" cellspacing="0">
                	    <tr>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Send Company Requests</td>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/panelrightcorner.gif" hspace="0" border="0" align="top"/></td>
	                        <td style="vertical-align:bottom;" colspan="30" width="90%" class="TABLETOPBORDER">&nbsp;</td>
	                    </tr>
	                	</table>
            		</td>
        		</tr>
		        <tr class="CONTENT">
	    	        <td width="1" class="TABLEBORDERLEFT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		    	    <td height="100%" width="100%" class="VIEWBOXCAPTION" >
                        <asp:label id="Label2" runat="server" CssClass="VIEWBOXCAPTION">Select the person to whom the Financial Statement and Reference List request will be sent.</asp:label>

                        <asp:Repeater ID="repPersons" runat="server">
                            <HeaderTemplate>
                                <asp:Label ID="lblCount" runat="server" />
                                <div style="height:600px; overflow-y: scroll;">
                                    <table width="100%" class="CONTENTGRID" cellspacing="0" cellpadding="1">
                                    <tr>
                                        <td class="GRIDHEAD" style="width:75px;">&nbsp;</td>
                                        <td class="GRIDHEAD" align="center">Person</td>
                                        <td class="GRIDHEAD" align="left">Title</td>
                                        <td class="GRIDHEAD" align="left">Email</td>
                                    </tr>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <!-- <%# GetRowClass() %> -->
                                <tr>
                                    <td class="<%# _szRowClass %>" align="center"><input type="radio" name="rbPersonID" value="<%# Eval("pers_PersonID")%>" /></td>
                                    <td class="<%# _szRowClass %>" align="left"><%# Eval("Pers_FullName") %>&nbsp;</td>
                                    <td class="<%# _szRowClass %>" align="left"><%# Eval("peli_PRTitle")%>&nbsp;</td>
                                    <td class="<%# _szRowClass %>" align="left"><%# Eval("emai_EmailAddress")%>&nbsp;
                                        <input type="hidden" name="personEmail<%# Eval("pers_PersonID")%>" value="<%# Eval("emai_EmailAddress")%>" />
                                    </td>
                                </tr>    
                            </ItemTemplate>        
                            <FooterTemplate>
                                    </table>
                                </div>
                            </FooterTemplate>
                        </asp:Repeater>   
	    			</td>
	    			<td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/img/backgrounds/tabletopborder.gif" hspace="0" border="0" align="top"/></td>
		    	</tr>
     
				<tr height=1><td width="1" colspan="3" class="TABLEBORDERBOTTOM"></td></tr>
     			</table>   
        	</td>
		    			
			<td valign="top" width="5%" style="right:130px;padding-top:87.25px;">
				<table class="Button">
				<tr id="trContinue" runat="server">
					<td class="Button">
						<table cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td><asp:HyperLink ID="hlContinueImg" BorderStyle="None" ImageAlign="Middle" CssClass="er_buttonItemImg" Target="_parent" runat="server" /></td>
							<td></td>
							<td><asp:HyperLink ID="hlContinue" Text="Continue" CssClass="er_buttonItem" Target="_parent" runat="server" /></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr id="trCancel" runat="server">
					<td class="Button">
						<table cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td><asp:HyperLink ID="hlCancelImg" BorderStyle="None" ImageAlign="Middle" CssClass="er_buttonItemImg" Target="_parent" runat="server" /></td>
							<td></td>
							<td><asp:HyperLink ID="hlCancel" Text="Cancel" CssClass="er_buttonItem" Target="_parent" runat="server" /></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr id="trSave" runat="server">
					<td class="Button">
						<table cellpadding="0" cellspacing="0" border="0" id="tblSaveButton" runat="server">
						<tr>
							<td><asp:HyperLink ID="imgbtnSave" CssClass="er_buttonItemImg" OnClick="btnSaveOnClick"  OnClientClick="return onSave();" runat="server" BorderStyle="None" ImageAlign="Middle" /></td>
							<td></td>
							<td><asp:LinkButton ID="btnSave" Text="Send" CssClass="er_buttonItem" OnClick="btnSaveOnClick" OnClientClick="return onSave();" runat="server" /></td>
						</tr>
						</table>
					</td>
				</tr>
				</table>
			</td>	
			
			
        </tr>


        </tbody>			
        </table>
	</td>
</tr>
</table> 


    </form>

<script type="text/javascript">
    function onSave() {

        oListControl = document.getElementsByName("rbPersonID");
        for (var i = 0; i < oListControl.length; i++) {
            if (oListControl[i].checked) {

                return confirm("Are you sure you want to send the Financial Statement and Reference List request?");
            }
        }

        alert("Please select a person to whom to send the request.");
        return false;
        
    }
</script>
</body>
</html>
			