<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GenerateLRL.aspx.cs" Inherits="PRCo.BBS.CRM.GenerateLRL" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Generate Listing Report Letters</title>
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

        function CheckPartialList(szPrefix, bGreaterThan) {

            var bFoundFirstChecked = false;
            
            var oCheckboxes = document.body.getElementsByTagName("INPUT");
            for (var i = 0; i < oCheckboxes.length; i++) {
                if ((oCheckboxes[i].type == "checkbox") &&
		            (oCheckboxes[i].name.indexOf(szPrefix) == 0)) {

                    if (oCheckboxes[i].checked) {
                        bFoundFirstChecked = true;
                    } else {

                        if (bGreaterThan) {
                            if (bFoundFirstChecked) {
                                oCheckboxes[i].checked = true;
                            }
                        } else {
                            if (!bFoundFirstChecked) {
                                oCheckboxes[i].checked = true;
                            }
                        }
                    }
                }
            }
        }

        function ToggleFilterByCriteria() {
            if (document.getElementById('rbFilterTypeCriteria').checked) {
                document.getElementById('tblDoubleCheck').style.display = 'none';
                document.getElementById('tblCompanyID').style.display = 'none';
                document.getElementById('tblFilter').style.display = '';
                document.getElementById('tblIndustryType').style.display = '';
                

            } else if (document.getElementById('rbFilterTypeIDs').checked) {
               document.getElementById('tblDoubleCheck').style.display = 'none';   
               document.getElementById('tblFilter').style.display = 'none';
               document.getElementById('tblCompanyID').style.display = '';
               document.getElementById('tblIndustryType').style.display = 'none';

           } else if (document.getElementById('rbFilterTypeDoubleCheck').checked) {
               document.getElementById('tblFilter').style.display = 'none';
               document.getElementById('tblCompanyID').style.display = 'none';
               document.getElementById('tblDoubleCheck').style.display = '';
               document.getElementById('tblIndustryType').style.display = '';
           }
        }



        function GenerateLRL() {
            var szErrorMsg = "";
            
            if ((document.getElementById("rbFilterTypeIDs").checked) &&
                (document.getElementById("txtCompanyIDs").value == "")) {
                szErrorMsg += "\n- Please specify Company IDs to generate letters for.";
            }

            if (szErrorMsg != "") {
                alert("Please correct the following error(s):\n\n" + szErrorMsg);
                return false;
            }

            var szTestClause = "  This is NOT a test batch so Interactions WILL BE generated.";
            if (document.getElementById("cbTestOnly").checked) {
                szTestClause = "  This IS A test batch so Interactions will NOT be generated."
            }

            if (document.getElementById('rbFilterTypeDoubleCheck').checked) {

                if ((document.getElementById("cblIndustryType_0").checked) ||
                    (document.getElementById("cblIndustryType_1").checked) ||
                    (document.getElementById("cblIndustryType_2").checked) ||
                    (document.getElementById("cblIndustryType_3").checked)) {
                    return confirm("The 'Double Check' process will generate letters for " + document.getElementById("hidCompaniesWOLetters").value + " companies."  + szTestClause + "  Do you want to continue?");
                } else {
                    alert("When generating 'Double Check' letters, at least one Industry Type must be selected.");
                    return false;
                }
            } else {
                return confirm("Are you sure you want to generate the letters?" + szTestClause);
            }
            
            
            return false;
        }
            
    </script>    
</head>
<body>

    <form id="form1" runat="server">

    <ajax:ScriptManager ID="ScriptManager1" EnablePartialRendering="true" EnableScriptGlobalization="true"  runat="server" />

    <asp:TextBox visible="false" id="hidSID" runat="server"/>
    <asp:TextBox visible="false" id="hidUserID" runat="server"/>
    
    <input type="hidden" id="hidCompaniesWOLetters" runat="server" />
    <input type="hidden" id="hidConfirmationCount" runat="server" />


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
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Current Batch Info</td>
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
		    	    
		    	    
                        <asp:HiddenField ID="hidBatchStart"   runat="server" />
                        <asp:HiddenField ID="hidBatchEnd"   runat="server" />
                        <table width="100%">
                        <tr>
                            <td width="50%">
                                <span class="VIEWBOXCAPTION">Batch:</span><br/>
                                <span class="VIEWBOX" ><asp:Literal ID="litBatch" runat="server" /></span>
                            </td>
                            <td width="50%">
                                <span class="VIEWBOXCAPTION">Listing Letters Sent:</span><br/>
                                <span class="VIEWBOX" ><asp:Literal ID="litLetterCount" runat="server" /></span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                            </td>
                            <td>
                                <span class="VIEWBOXCAPTION">Companies Without Letters Generated:</span><br/>
                                <span class="VIEWBOX" ><asp:Literal ID="litCompaniesWOLetters" runat="server" /></span>
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
			
			<!-- This is the button column -->
			<td valign="top" width="5%">
				<table class="Button">
				<tr>
					<td class="Button">
						<table cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td><asp:HyperLink ID="hlViewBatchesImg" ImageAlign="Middle" CssClass="er_buttonItemImg" runat="server" BorderStyle="None" Target="_parent" /></td>
							<td>&nbsp;</td>
							<td><asp:HyperLink ID="hlViewBatches" Text="View Batches" CssClass="er_buttonItem" runat="server" Target="_parent" /></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td class="Button">
						<table cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td><asp:HyperLink ID="imgbtnGenerate" CssClass="er_buttonItemImg" OnClick="GenerateLRLs" runat="server" BorderStyle="None" ImageAlign="Middle" /></td>
							<td>&nbsp;</td>
							<td><asp:LinkButton ID="btnGenerate" Text="Generate LRL" CssClass="er_buttonItem" OnClick="GenerateLRLs" runat="server" /></td>
						</tr>
						</table>
					</td>
				</tr>
				
				</table>
			</td>	
			<!-- End button column -->
			
        </tr>


        <tr>
        	<td style="width:90%;" valign="top">
                
				<!-- Section Tab Header -->
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
        		<tr class="GridHeader">
		            <td colspan="2">
        		        <table  border="0" cellpadding="0" cellspacing="0">
                	    <tr>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Processing Options</td>
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
                            <td width="25%">
                                <span class="VIEWBOXCAPTION"><asp:CheckBox ID="cbTestOnly" Text="Test Only" runat="server" /></span>                            
                            </td>
                            <td width="25%">
                                <span class="VIEWBOXCAPTION">Letter Type:</span> <br />
                                <span class="VIEWBOX"><asp:DropDownList ID="ddlLetterType" runat="server" AutoPostBack="true" OnSelectedIndexChanged="OnLetterTypeChange" /></span>
                            </td>
                            <td width="25%" id="tdCLDate">
                                <span class="VIEWBOXCAPTION">Connection List Date:</span> <br />
                                <span class="VIEWBOX" ><asp:TextBox ID="txtCLDate" MaxLength="10" Columns="10" runat="server" /></span>
                            </td>
                            <td width="25%" id="tdDeadlineDate">
                                <span class="VIEWBOXCAPTION">Publication Deadline:</span> <br />
                                <span class="VIEWBOX" ><asp:TextBox ID="txtDeadlineDate" MaxLength="10" Columns="10" AutoPostBack="true" OnTextChanged="OnLetterTypeChange" runat="server" /></span>
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
        <tr>
        	<td style="width:90%;" valign="top">
                
				<!-- Section Tab Header -->
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
        		<tr class="GridHeader">
		            <td colspan="2">
        		        <table  border="0" cellpadding="0" cellspacing="0">
                	    <tr>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Select Companies</td>
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

                        <div style="text-align:center">
                            <span class="VIEWBOXCAPTION"> Filter By :</span>
                            <span class="VIEWBOX" >
                            
                                <input type="radio" name="rbFilterType" id="rbFilterTypeCriteria" value="Criteria" onclick="ToggleFilterByCriteria();" /><label for="rbFilterTypeCriteria">Criteria</label>
                                <input type="radio" name="rbFilterType" id="rbFilterTypeIDs" value="IDs" onclick="ToggleFilterByCriteria();" checked /><label for="rbFilterTypeIDs">Specify Company IDs</label>
                                <input type="radio" name="rbFilterType" id="rbFilterTypeDoubleCheck" value="DoubleCheck" onclick="ToggleFilterByCriteria();" /><label for="rbFilterTypeDoubleCheck">Generate "Double Check" Batch</label>
                            
                            </span>                        
                        </div>
                        
                        <div  id="tblIndustryType">
                        <table width="100%">
                        <tr>
                            <td><span class="VIEWBOXCAPTION">Industry Type:</span><br/>
                                <span class="VIEWBOX" ><asp:CheckBoxList ID="cblIndustryType" RepeatDirection="Horizontal" RepeatColumns="5" Width="100%" runat="server" /> </span>
                            </td>
                        </tr>
                        </table>
                        </div>
                        
                        <div  id="tblFilter">
                        <table width="100%">
                        <tr>
                            <td><span class="VIEWBOXCAPTION">Listing Status:</span><br/>
                                <span class="VIEWBOX" ><asp:CheckBoxList ID="cblListingStatus" RepeatDirection="Horizontal" RepeatColumns="5" Width="100%" runat="server">
                                    <asp:ListItem Text="Listed" Value="L" Selected="True" />
                                    <asp:ListItem Text="Hold" Value="H"  />
                                    <asp:ListItem Text="Listing Verification Pending" Value="LUV"  />
                                    </asp:CheckBoxList>
                                 </span>
                            </td>
                        </tr>
                        
                        <tr>
                            <td><span class="VIEWBOXCAPTION">Rated?</span><br/>
                                <span class="VIEWBOX" >
                                    <asp:RadioButtonList ID="rblRated"  RepeatDirection="Horizontal" RepeatColumns="3" Width="100%" runat="server">
                                        <asp:ListItem Value="B" Text="Both Rated and Unrated Companies" Selected="True" />
                                        <asp:ListItem Value="UR" Text="Only Unrated Companies" />
                                        <asp:ListItem Value="R" Text="Only Rated Companies" />
                                    </asp:RadioButtonList>
                                </span>
                            </td>
                        </tr>

                        <tr>
                            <td><span class="VIEWBOXCAPTION">Members?</span><br/>
                                <span class="VIEWBOX" >
                                    <asp:RadioButtonList ID="rblMembers" RepeatDirection="Horizontal" RepeatColumns="3" Width="100%" runat="server">
                                        <asp:ListItem Value="B" Text="Both Member and Non-Member Companies"  Selected="True" />
                                        <asp:ListItem Value="NM" Text="Only Non-Member Companies" />
                                        <asp:ListItem Value="M" Text="Only Member Companies" />
                                    </asp:RadioButtonList>
                                </span>
                            </td>
                        </tr>


                        <tr><td><br /><span class="VIEWBOXCAPTION">Country:</span><br/>
                                <span class="VIEWBOX" >
                                <asp:Panel ID="Panel1" HorizontalAlign="Center" runat="server">
                                [ <a href="javascript:CheckPartialList('cblCountry', false);__doPostBack('cblCountry','OnSelectedIndexChanged');">Select All Less</a> | <a href="javascript:CheckPartialList('cblCountry', true);__doPostBack('cblCountry','OnSelectedIndexChanged');">Select All Greater</a> |
                                
                                 <a href="javascript:CheckAll('cblCountry', true);__doPostBack('cblCountry','OnSelectedIndexChanged');">Select All</a> | <a href="javascript:CheckAll('cblCountry', false);__doPostBack('cblCountry','OnSelectedIndexChanged');">Deselect All</a> ]
                                </asp:Panel>
                                <asp:CheckBoxList ID="cblCountry" RepeatDirection="Horizontal" RepeatColumns="5" Width="100%" runat="server" AutoPostBack="true" OnSelectedIndexChanged="BindState" /></span>
                            </td>
                        </tr>

                        <tr><td>
                            <br />
                            <span class="VIEWBOXCAPTION">State/Province:</span><br/>
                            <span class="VIEWBOX" >
                                <em><asp:Literal ID="litState" runat="server"/></em>
                                
                                <asp:Panel ID="pnlStateSelect" HorizontalAlign="Center" runat="server">
                                [ <a href="javascript:CheckPartialList('cblState', false);__doPostBack('cblState','OnSelectedIndexChanged');">Select All Less</a> | <a href="javascript:CheckPartialList('cblState', true);__doPostBack('cblState','OnSelectedIndexChanged');">Select All Greater</a> | <a href="javascript:CheckAll('cblState', true);__doPostBack('cblState','OnSelectedIndexChanged');">Select All</a> | <a href="javascript:CheckAll('cblState', false);__doPostBack('cblState','OnSelectedIndexChanged');">Deselect All</a> ]
                                </asp:Panel>
                                
                                <asp:CheckBoxList ID="cblState" RepeatDirection="Horizontal" RepeatColumns="5" Width="100%" AutoPostBack="true" OnSelectedIndexChanged="BindCity" runat="server" /></span></td>
                        </tr>

                        <tr><td><br /><span class="VIEWBOXCAPTION">City:</span><br/>

                                <asp:UpdatePanel ID="updpnlCitySelect" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <span class="VIEWBOX" >
                                    <em><asp:Literal ID="litCity" runat="server"/></em>

                                    <asp:Panel ID="pnlCitySelect" HorizontalAlign="Center" runat="server">
                                    [ <a href="javascript:CheckPartialList('cblCity', false);">Select All Less</a> | <a href="javascript:CheckPartialList('cblCity', true);">Select All Greater</a> | <a href="javascript:CheckAll('cblCity', true);">Select All</a> | <a href="javascript:CheckAll('cblCity', false);">Deselect All</a> ]
                                    </asp:Panel>
                        
                                    <asp:CheckBoxList ID="cblCity" RepeatDirection="Horizontal" RepeatColumns="5" Width="100%" runat="server" /></span>
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="cblState" EventName="SelectedIndexChanged" />
                                </Triggers>
                                </asp:UpdatePanel>
                                </td>
                        </tr>
                        </table>
                        </div>
                        
                        <div id="tblCompanyID">
                        <table width="100%">
                        <tr><td><span class="VIEWBOXCAPTION">Company IDs:</span><br/>
                                <span class="VIEWBOX" ><asp:TextBox ID="txtCompanyIDs" Columns="120" Rows="10" TextMode="MultiLine" runat="server" />
                                </span></td>
                        </tr>
                        </table>
                        </div>

                        <div id="tblDoubleCheck">
                            <span class="VIEWBOXCAPTION">Geneate Listing Report Letters for those companies that have yet to receive one for this batch.</span><br />
                            <span class="VIEWBOX" >Companies Without Letters Generated: <asp:Literal id="litCompaniesWOLetters2" runat="server" /></span>
                        </div>
                        &nbsp;
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


<script type="text/javascript">
    ToggleFilterByCriteria();
</script>

    </form>
</body>
</html>
