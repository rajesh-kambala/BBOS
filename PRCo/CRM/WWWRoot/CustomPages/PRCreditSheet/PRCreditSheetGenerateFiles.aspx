<%@ Page Language="C#" ValidateRequest="false" AutoEventWireup="true" CodeBehind="PRCreditSheetGenerateFiles.aspx.cs" Inherits="PRCo.BBS.CRM.PRCreditSheetGenerateFiles" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title></title>
    
    <asp:Literal ID="Literal1" Visible="false" runat="server">
        <link href="../../prco.css" rel="stylesheet" type="text/css" />
        <link href="../../eware.css" rel="stylesheet" type="text/css" />
    </asp:Literal>

    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>

    <script type="text/javascript">
        function openPreviewReport(sReportType, sMsgHeader, sMsg, bHighlightMarketingMsg) {

            var sortType = "I";
            if (sReportType == "EXUPD") {
                sortType = "I-K";
            }

            if (bHighlightMarketingMsg == undefined)
                bHighlightMarketingMsg = false;

            var sReportURL = document.getElementById("hidSSRSURL").value;
            sReportURL += "/BBOSMemberReports/CreditSheetReportEmail";
            sReportURL += "&IndustryType='P','T','S'&SortType=" + sortType + "&ReportType=" + sReportType + "&MessageHdr=" + encodeURIComponent(sMsgHeader) + "&Message=" + encodeURIComponent(sMsg) + "&HighlightMarketingMsg=" + bHighlightMarketingMsg;
            sReportURL += "&rs:format=PDF";

            window.open(sReportURL,
				"Reports",
				"location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes,width=600,height=300", true);

        }

        function confirmCSGeneration() {
            var dtLastCSDate = new Date(document.getElementById("hidLastCSDate").value);

            var testMsg = "";
            if (!document.getElementById("cbTest").checked) {
                testMsg = "  NOTE: THIS IS NOT A TEST BATCH";
            }

            if (IsDateToday(dtLastCSDate)) {
                return confirm("The Credit Sheet Report has already been sent today.  Are you sure you want to send them again?" + testMsg);
            } else {
                return confirm('Are you sure you want to send the Credit Sheet Report?' + testMsg);
            }
        }

        function confirmEXGeneration() {
            var dtLastEXDate = new Date(document.getElementById("hidLastEXDate").value);

            if (IsDateToday(dtLastEXDate)) {
                return confirm("The Express Update files have already been generated today.  Are you sure you want to generate them again?");
            } else {
                return confirm('Are you sure you want to generate the Express Update Report and recipient files?');
            }
        }

        function IsDateToday(dtDate) {
            var dtWorkDate = new Date(dtDate.getFullYear(), dtDate.getMonth(), dtDate.getDate(), 0, 0, 0, 0);

            var dtTempToday = new Date();
            var dtToday = new Date(dtTempToday.getFullYear(), dtTempToday.getMonth(), dtTempToday.getDate(), 0, 0, 0, 0);

            if (dtWorkDate.getTime() == dtToday.getTime()) {
                return true;
            }

            return false;
        }

        function toggleCSTest() {
            if (document.getElementById("cbTest").checked) {
                document.getElementById("txtCSTestUsers").disabled = false;
            } else {
                document.getElementById("txtCSTestUsers").disabled = true;
            }
        }
        
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:HiddenField ID="hidSSRSURL" runat="server" />
    <asp:HiddenField ID="hidLastCSDate" runat="server" />
    <asp:HiddenField ID="hidLastEXDate" runat="server" />
    <asp:TextBox visible="False" id="hidUserID" runat="server"/>
    
    <div style="height:800px; overflow:auto">
    
<table width="100%" style="margin-top:5px;" cols="3">
<tr>
	<td style="width:15px;"></td>
    <td style="vertical-align:top;">

    
        <table width="100%">
        <tr>
            <td>
                <asp:label id="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" />
            </td>
        </tr>
        </table>

        <table class="MessageContent" runat="server" id="tblInfoMsg"><tr><td>
            <asp:Literal id="lblnfoMsg" runat="server"/>
        </td></tr></table>

                
    
		<table width="100%" ID="Table2" border="0">
        <tbody> 
        <tr>
        
        	<td style="width:90%;" valign="top">
   				<table width="100%" border="0" cellpadding="0" cellspacing="0">
				
				<!-- Section Tab Header -->
        		<tr class="GridHeader">
		            <td colspan="2">
        		        <table border="0" cellpadding="0" cellspacing="0" ID="Table6">
                	    <tr>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Weekly Credit Sheet Update Report</td>
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
		    	    <td width="100%" class="VIEWBOX">

                    <table>
                    <tr>
                        <td style="vertical-align:top;width:200px;">
                            <span class="VIEWBOXCAPTION">Last Report Date:</span><br/>
                            <span class="VIEWBOX"><asp:Literal ID="litCSLastReportDate" runat="server" /></span>
                        </td>
                        <td style="vertical-align:top;">
                            <span class="VIEWBOXCAPTION">Last Report Item Count:</span><br/>
                            <span class="VIEWBOX"><asp:Literal ID="litCSLastReportItemCount" runat="server" /></span>
                        </td>

                        <td style="vertical-align:top;">
                            <span class="VIEWBOXCAPTION">Next Report Item Count:</span><br/>
                            <span class="VIEWBOX" style="width:100px"><asp:Literal ID="litCSNextReportItemCount" runat="server" /></span>
                        </td>
                    </tr>
                    
                    <tr><td>&nbsp;</td></tr>

                    <tr>
                        <td>
                            <span class="VIEWBOXCAPTION">Report Message Header:</span><br/>
                            <span class="VIEWBOX"><asp:TextBox ID="txtCSMessageHeader" MaxLength="100" width="235px" runat="server" /></span>
                        </td>


                        <td>
                            <span class="VIEWBOXCAPTION" style="vertical-align:top;">Current Email Image:</span><br/>
                            <span class="VIEWBOX"><asp:HyperLink ID="hlCSImg" Target="_blank" runat="server" /> &nbsp; <asp:CheckBox ID="cbCSRemoveImage" Text="Remove Image" runat="server" /></span>
                        </td>
                    </tr>                      


                    <tr>
                        <td style="padding-right:15px;vertical-align:top;" rowspan="2">
                            <span class="VIEWBOXCAPTION">Report Message:</span><br/>
                            <span class="VIEWBOX"><asp:TextBox ID="txtCSMessage" MaxLength="500" TextMode="MultiLine" Rows="3"  width="235px"  runat="server"/></span>
                        </td>

                        <td colspan="2" style="vertical-align:top;">
                            <span class="VIEWBOXCAPTION">Image to Include in Email:</span><br/>
                            <span class="VIEWBOX" ><asp:FileUpload ID="upCSImg"  Width="500" CssClass="EDIT"  runat="server" /></span>
                        </td>

                    </tr>                        

                    <tr>
                        <td colspan="2" style="vertical-align:top;">
                            <span class="VIEWBOXCAPTION">URL for Email Image:</span><br/>
                            <span class="VIEWBOX" ><asp:TextBox ID="txtCSImgLink"  Width="500" CssClass="EDIT"  runat="server" /></span>
                        </td>
                    </tr>                        

                    <tr>
                        <td style="vertical-align:top;" colspan="2">
                            <span class="VIEWBOXCAPTION" style="width:150px">Test Batch:</span><br/>
                            <span class="VIEWBOX"><asp:CheckBox ID="cbTest" runat="server" onclick="toggleCSTest();" /> &nbsp;
                                     <asp:TextBox ID="txtCSTestUsers" MaxLength="50" Columns="50" runat="server" />
                            </span>
                        </td>
                    </tr>

                    <tr><td>&nbsp;</td></tr>

                    <tr>
                        <td style="vertical-align:top;" colspan="2">
                            <span class="VIEWBOXCAPTION" style="width:150px">Highlight Marketing Message:</span><br/>
                            <span class="VIEWBOX">
                                <asp:CheckBox ID="cbHighlightMarketingMsg" runat="server" />
                            </span>
                        </td>
                    </tr>

                    <tr><td>&nbsp;</td></tr>

                    <tr>
                        <td colspan="4">
                            <button style="width:225px" onclick="openPreviewReport('CSUPD', document.getElementById('txtCSMessageHeader').value, document.getElementById('txtCSMessage').value, document.getElementById('cbHighlightMarketingMsg').checked);">Preview Credit Sheet Report</button>
                            <asp:Button ID="btnCSSaveSettings" OnClick="btnSaveCreditSheetSetting" Text="Save Credit Sheet Settings" Width="225px" runat="server" />
                            <asp:Button ID="btnCSGenerateFiles" OnClientClick="return confirmCSGeneration();" OnClick="btnSendCreditSheet" Text="Generate Credit Sheet Report" Width="225px" runat="server" />
                            <asp:Button ID="btnCSResetLastReportDate" Width="225px" OnClick="btnResetLastCSDate" OnClientClick="return confirm('Are you sure you want to reset the last report date?  This will result in the items included in the last report being included in the next report');" Text="Reset Last Report Date" runat="server" />
                        </td>
                    </tr>
                    </table>

	    			</td>
	    			<td width="1" class="TABLEBORDERRIGHT"><img alt="" src="/<%= _szAppName%>/Themes/img/color/backgrounds/tabletopborder.gif" HSPACE="0" BORDER="0" ALIGN="top"/></td>
		    	</tr>
     
    
                <tr height="1"><td colspan="3" width="1px" class="TABLEBORDERBOTTOM"></td></tr>
        		<tr>
          		  <td class="ROWGap">&nbsp;</td>
        		</tr>


     			</table>   <!-- End Table3-->  
        	</td>        
        
        
			<!-- This is the button column -->
			<td valign="top" width="5%">
				<table class="Button">
				<tr>
					<td class="Button">
						<table cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td><asp:HyperLink ID="imgbtnCreditSheetPublish" CssClass="er_buttonItemImg" runat="server" BorderStyle="None" ImageAlign="Middle" Target="_parent" /></td>
							<td>&nbsp;</td>
							<td><asp:HyperLink ID="btnCreditSheetPublish" Text="Credit Sheet Publish" CssClass="er_buttonItem" runat="server" Target="_parent" /></td>

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
   				<table width="100%" border="0" cellpadding="0" cellspacing="0">
				
				<!-- Section Tab Header -->
        		<tr class="GridHeader">
		            <td colspan="2">
        		        <table border="0" cellpadding="0" cellspacing="0" ID="Table5">
                	    <tr>
	                        <td style="vertical-align:bottom;" class="PanelCorners"><img alt="" src="/crm/Themes/img/ergonomic/backgrounds/paneleftcorner.jpg" hspace="0" border="0" align="top"/></td>
	                        <td style="white-space:nowrap" width="10%" class="PANEREPEAT">Daily Express Update Report</td>
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
                        <td style="vertical-align:top;">
                            <span class="VIEWBOXCAPTION">Last Report Date:</span><br/>
                            <span class="VIEWBOX"><asp:Literal ID="litEXLastReportDate" runat="server" /></span>
                            <asp:HiddenField ID="EXBatchID" runat="server" />
                        </td>

                        <td style="vertical-align:top;">
                            <span class="VIEWBOXCAPTION">Last Report Item Count:</span><br/>
                            <span class="VIEWBOX" style="width:100px"><asp:Literal ID="litEXLastReportItemCount" runat="server" /></span>
                        </td>

                        <td style="vertical-align:top;">
                            <span class="VIEWBOXCAPTION">Next Report Item Count:</span><br/>
                            <span class="VIEWBOX" style="width:100px"><asp:Literal ID="litEXNextReportItemCount" runat="server" /></span>
                        </td>

                    </tr>

                    <tr><td>&nbsp;</td></tr>

                    <tr>
                        <td>
                            <span class="VIEWBOXCAPTION">Report Message Header:</span><br/>
                            <span class="VIEWBOX"><asp:TextBox ID="txtEXMessageHeader" MaxLength="100" width="235px" runat="server" /></span>
                        </td>

                        <td>
                            <span class="VIEWBOXCAPTION" style="vertical-align:top;">Current Email Image:</span><br/>
                            <span class="VIEWBOX"><asp:HyperLink ID="hlExImg" Target="_blank" runat="server" /><asp:HiddenField ID="hdnExImg" runat="server" /> &nbsp; <asp:CheckBox ID="cbExRemoveImage" Text="Remove Image" runat="server" /></span>
                        </td>

                    </tr>                      

                    <tr>
                        <td style="padding-right:15px;vertical-align:top;" rowspan="2">
                            <span class="VIEWBOXCAPTION">Report Message:</span><br/>
                            <span class="VIEWBOX"><asp:TextBox ID="txtEXMessage" MaxLength="500" TextMode="MultiLine" Rows="3"  width="235px"  runat="server" /></span>
                        </td>


                        <td colspan="2" style="vertical-align:top;">
                            <span class="VIEWBOXCAPTION">Image to Include in Email:</span><br/>
                            <span class="VIEWBOX" ><asp:FileUpload ID="upEXImg"  Width="500" CssClass="EDIT"  runat="server" /></span>
                        </td>
                    </tr>                     

                    <tr>
                        <td colspan="2" style="vertical-align:top;">
                            <span class="VIEWBOXCAPTION">URL for Email Image:</span><br/>
                            <span class="VIEWBOX" ><asp:TextBox ID="txtEXImgLink"  Width="500" CssClass="EDIT"  runat="server" /></span>
                        </td>
                    </tr>                            
                    <tr><td>&nbsp;</td></tr>

                    <tr>
                        <td colspan="4">
                            <button style="width:225px" onclick="openPreviewReport('EXUPD', document.getElementById('txtEXMessageHeader').value, document.getElementById('txtEXMessage').value);">Preview Express Update Report</button>
                            <asp:Button ID="btnSaveEXSettings" Width="225px" OnClick="btnSaveExpressUpdate" Text="Save Express Update Settings" runat="server" />
                            <asp:Button ID="btnEXResetLastReportDate" Width="225px" OnClick="btnResetLastEXDate" OnClientClick="return confirm('Are you sure you want to reset the last report date?  This will result in the items included in the last report being included in the next report');" Text="Reset Last Report Date" runat="server" />
                            <asp:Button Visible="false" ID="btnEXGenerateFiles" OnClientClick="return confirmEXGeneration();" OnClick="btnGenerateEXFiles" Text="Generate Express Update Report" Width="225px" runat="server" />
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


<script type="text/javascript">
    toggleCSTest();

    $(document).ready(function () {
        $("#<%=txtCSMessage.ClientID %>").keypress(function () {
            if (this.value.length >= 500) {
                return false;
            }
        });
    });


</script>    
    
    </div>
    </form>
</body>
</html>
